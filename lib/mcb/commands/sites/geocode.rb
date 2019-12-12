name "geocode"
summary "Batch geocode Sites"
usage "geocode [options] [<id>...]"
option :s, "sleep", "time to sleep between each request", argument: :optional, default: 0.25, transform: method(:Float)
option :b, "batch_size", "batch size", argument: :optional, default: 100, transform: method(:Integer)

instance_eval(&MCB.remote_connect_options)

require "geocoder"

# TODO: Once Site codes have been changed to three digit values
# update this command to geocode by site code
# See: providers/geocode.rb

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  if args.any?
    Site
      .where(id: args.to_a)
      .find_each(batch_size: opts[:batch_size]) do |site|
        MCB.geocode(obj: site, sleep: opts[:sleep])
      end
  else
    Site
      .not_geocoded
      .find_each(batch_size: opts[:batch_size]) do |site|
        MCB.geocode(obj: site, sleep: opts[:sleep])
      end
  end
end
