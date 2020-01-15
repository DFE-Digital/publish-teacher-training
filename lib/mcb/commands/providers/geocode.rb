name "geocode"
summary "Batch geocode Providers"
usage "geocode [options] [<code>...]"
option :s, "sleep", "time to sleep between each request", argument: :optional, default: 0.25, transform: method(:Float)
option :b, "batch_size", "batch size", argument: :optional, default: 100, transform: method(:Integer)

instance_eval(&MCB.remote_connect_options)

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  if args.any?
    recruitment_cycle = MCB.get_recruitment_cycle(opts)
    providers = recruitment_cycle.providers

    providers
      .where(provider_code: args.map(&:upcase))
      .find_each(batch_size: opts[:batch_size]) do |provider|
        MCB.geocode(obj: provider, sleep: opts[:sleep])
      end
  else
    Provider
      .not_geocoded.find_each(batch_size: opts[:batch_size]) do |provider|
        MCB.geocode(obj: provider, sleep: opts[:sleep])
      end
  end
end
