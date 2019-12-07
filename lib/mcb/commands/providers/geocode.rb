summary "Batch geocode Provider addresses"
option :s, "sleep", "time to sleep between each request", argument: :required, default: 0.5, transform: method(:Float)
option :b, "batch_size", "batch size", argument: :required, default: 100, transform: method(:Integer)

run do |opts, args, _cmd| # rubocop:disable Metrics/BlockLength
  MCB.init_rails(opts)
  geocode_record = lambda { |obj|
    obj.geocode
    obj.save
    sleep(opts[:sleep])
  }

  require "geocoder"

  if args.any?
    args.each do |id|
      provider = Provider.find(id)
      geocode_record.call(provider)
    end
  else
    Provider.not_geocoded.find_each(batch_size: opts[:batch_size]) do |obj|
      geocode_record.call(obj)
    end
  end
end
