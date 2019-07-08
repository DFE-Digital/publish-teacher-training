summary 'Edit information about provider'
param :code, transform: ->(code) { code.upcase }

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  MCB::ProviderEditor.new(
    requester: User.find_by!(email: MCB.config[:email]),
    provider: Provider.find_by!(provider_code: args[:code])
  ).run
end
