summary 'Update a provider so that it will be at the top of the apiv1 results'
usage 'touch <provider_code>'
param :provider_code, transform: ->(code) { code.upcase }

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  provider = Provider.find_by!(provider_code: args[:provider_code])
  provider.touch
  provider.update! audit_comment: 'timestamps updated to expose in api v1'
end
