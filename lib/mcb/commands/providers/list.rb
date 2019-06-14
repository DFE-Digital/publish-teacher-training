name 'list'
summary 'List providers in db'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  providers = if args.any?
                Provider.where(provider_code: args.to_a.map(&:upcase))
              else
                Provider.all
              end

  tp.set :capitalize_headers, false

  puts "\nProviders:"
  tp providers, 'id', 'provider_code', 'provider_name', 'provider_type',
     'postcode'
end
