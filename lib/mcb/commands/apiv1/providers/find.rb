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
  opts[:all] ||= true

  verbose "looking for provider #{args[:code]}"

  (provider, last_context) = find_provider(args[:code], opts)

  if provider.nil?
    error "Provider with code '#{args[:code]}' not found"
    next
  end

  if opts[:json]
    puts JSON.pretty_generate(JSON.parse(provider.to_json))
  else
    print_provider_info(provider)
  end

  if opts[:all]
    puts 'All pages searched.'
  else
    puts 'Only first page of results searched (use -a to retrieve all).'
  end
  puts "To continue searching use the url: #{last_context[:next_url]}"

end

def find_provider(code, opts)
  MCB.each_v1_provider(opts).detect do |provider, _context|
    provider['institution_code'] == code
  end
end

def print_provider_info(provider)
  campuses = provider.delete('campuses')
  contacts = provider.delete('contacts')

  puts MCB::Render.provider_record provider
  puts "\n"
  puts MCB::Render.campuses_table campuses
  puts "\n"
  puts MCB::Render.contacts_table contacts
end
