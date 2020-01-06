summary "Edit information about provider"
option nil, :'accrediting-provider',
       "Update the accrediting provider attribute to accredited_body.",
       default: false
option nil, :'not-accrediting-provider',
       "Update the accrediting provider attribute to not_an_accredited_body.",
       default: false



run do |opts, args, _cmd|
  MCB.init_rails(opts)
  recruitment_cycle = MCB.get_recruitment_cycle(opts)
  providers = recruitment_cycle.providers
  binding.pry

  if opts[:"accrediting-provider"].present?
    args.each do |provider_code|
      provider = providers.find_by!(provider_code: provider_code.upcase)
      provider.update(accrediting_provider: "Y")
    end
  elsif opts[:"not-accrediting-provider"].present?
    args.each do |provider_code|
      provider = providers.find_by!(provider_code: provider_code.upcase)
      provider.update(accrediting_provider: "N")
    end
  else
    provider_code = args[0].upcase
    MCB::Editor::ProviderEditor.new(
      requester: User.find_by!(email: MCB.config[:email]),
      provider: recruitment_cycle.providers.find_by!(provider_code: provider_code),
    ).run
  end
end
