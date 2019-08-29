summary 'Create a new provider via the DB'

run do |opts, _args, _cmd|
  MCB.init_rails(opts)

  Provider.connection.transaction do
    provider = MCB.get_recruitment_cycle(opts).providers.build
    requester = User.find_by!(email: MCB.config[:email])

    MCB::Editor::ProviderEditor.new(
      provider: provider,
      requester: requester
    ).new_provider_wizard
  end
end
