name "geocode"
summary "Batch geocode addresses"
option :m, "model", "model to be geocoded", argument: :required, transform: method(:String)
option :s, "sleep", "time to sleep between each request", argument: :optional, default: 0.5, transform: method(:Float)
option :b, "batch_size", "batch size", argument: :optional, default: 100, transform: method(:Integer)

instance_eval(&MCB.remote_connect_options)

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  if opts[:model].nil?
    raise "Please pass in the model you want to geocode"
  end

  unless %w(provider site).include? opts[:model].downcase
    raise "You can only geocode Sites and Providers"
  end

  geocode_record = lambda { |obj|
    obj.geocode
    obj.save
    verbose "Geocoded #{obj.class} Id:#{obj.id} - #{obj}. New lat/long #{obj.latitude},#{obj.latitude} for full_address '#{obj.full_address}'"
    sleep(opts[:sleep])
  }

  model = opts[:model].classify.safe_constantize

  require "geocoder"

  if args.any?
    args.each do |id|
      record = model.find(id)
      geocode_record.call(record)
    end
  else
    model.not_geocoded.find_each(batch_size: opts[:batch_size]) do |obj|
      geocode_record.call(obj) if obj.needs_geolocation?
    end
  end
end
