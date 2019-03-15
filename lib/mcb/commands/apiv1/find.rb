name 'find'
summary 'Find a particular provider entry'
description <<~EODESCRIPTION
  Searches for a provider with the given provider code by iterating through all
  the pages of results provided from the provider endpoint, outputing the found
  record.
EODESCRIPTION
usage 'find [options] <code>'
param :code
option :j, 'json', 'show the returned JSON response'


run do |opts, args, _cmd|
  verbose "looking for provider #{args[:code]}"

  provider = each_v1_provider(opts).detect do |p|
    p['institution_code'] == args[:code]
  end

  if provider.nil?
    error "Provider with code '#{args[:code]}' not found"
    next
  end

  if opts[:json]
    puts JSON.pretty_generate(JSON.parse(provider.to_json))
  else
    campuses = provider.delete('campuses')
    contacts = provider.delete('contacts')
    puts Terminal::Table.new rows: provider
    puts ''
    puts "Campuses:"
    tp campuses
    puts ''
    puts "Contacts:"
    tp contacts
  end
end
