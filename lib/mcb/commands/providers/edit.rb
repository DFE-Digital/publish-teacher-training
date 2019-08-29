summary 'Edit information about provider'
param :code, transform: ->(code) { code.upcase }

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  MCB::Editor::ProviderEditor.new(
    requester: User.find_by!(email: MCB.config[:email]),
    provider: MCB.get_recruitment_cycle(opts).providers.find_by!(provider_code: args[:code])
  ).run
end
