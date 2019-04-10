summary 'Opt-out the provider'
param :code
usage 'optout <provider_code>'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  provider_code = args[:code]

  provider = Provider.find_by!(provider_code: provider_code)
  provider.update(opted_in: false)
  provider.courses.each { |c| c.touch(:changed_at) }
end
