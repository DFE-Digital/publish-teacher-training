summary 'Opt-in the provider'
param :code
usage 'optin <provider_code>'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  provider_code = args[:code]

  provider = Provider.find_by!(provider_code: provider_code)
  provider.update(opted_in: true)
  provider.courses.each { |c| c.touch(:changed_at) }
end
