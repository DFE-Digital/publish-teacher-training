summary 'Find a particular provider entry'
description <<~EODESCRIPTION
  Searches for a provider with the given provider code by iterating through all
  the pages of results provided from the provider endpoint, outputing the found
  record.
EODESCRIPTION
usage 'find [options] <code>'
param :code

option :j, 'json', 'show the returned JSON response'
option :P, 'max-pages', 'maximum number of pages to request',
       default: 20,
       argument: :required,
       transform: method(:Integer)


run do |opts, args, _cmd|
  opts = MCB.apiv1_opts(opts)
  opts[:all] ||= true

  verbose "looking for provider #{args[:code]}"

  (provider, last_context) = find_provider(args[:code], opts)

  if provider.nil?
    error "Provider with code '#{args[:code]}' not found"

    MCB::display_pages_received(page: last_context[:page],
                                max_pages: opts[:'max-pages'],
                                next_url: last_context[:next_url])
    next
  end

  if opts[:json]
    puts JSON.pretty_generate(JSON.parse(provider.to_json))
  else
    print_provider_info(provider)
  end
end

def find_provider(code, opts)
  last_context = nil
  MCB.each_v1_provider(opts).detect do |provider, context|
    last_context = context
    provider['institution_code'] == code
  end || [nil, last_context]
end

def print_provider_info(provider)
  campuses = provider.delete('campuses')
  contacts = provider.delete('contacts')

  puts MCB::Render::APIV1.provider_record provider
  puts "\n"
  puts MCB::Render::APIV1.campuses_table campuses
  puts "\n"
  puts MCB::Render::APIV1.contacts_table contacts
end
