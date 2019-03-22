name 'show'
summary 'Show information about provider'
param :code

run do |_opts, args, _cmd|
  init_rails

  code = args[:code]

  provider = Provider.find_by(provider_code: code)

  if provider.nil?
    error "Provider with code '#{code}' not found"
  else
    puts 'Provider:'
    puts Terminal::Table.new rows: provider.attributes

    puts "\nProvider Enrichments:"
    tp provider.enrichments, 'id', 'status', 'email', 'website', 'address1',
       'address2', 'address3', 'address4', 'postcode', 'telephone'

    puts "\nProvider Courses:"
    tp provider.courses
  end
end
