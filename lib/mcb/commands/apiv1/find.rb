name 'find'
summary 'Find a particular provider entry'
usage 'find [options] <code>'
param :code

run do |opts, args, _cmd|
  # We only need httparty for API V1 calls
  require 'httparty'

  puts "looking for provider #{args[:code]}"

  provider = each_v1_provider(opts).detect do |p|
    p['institution_code'] == args[:code]
  end

  if provider.nil?
    error "Provider with code '#{code}' not found"
  else
    campuses = provider.delete('campuses')
    puts Terminal::Table.new rows: provider
    puts ''
    puts "Campuses:"
    tp campuses
  end
end
