name "list"
usage "list [<code>...]"
summary "List providers in db"
option :x, :'extended-listing', "Display extra attributes in output"

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  recruitment_cycle = MCB.get_recruitment_cycle(opts)

  opts[:'extended-listing'] = opts[:'extended-listing']

  providers = recruitment_cycle.providers
  providers = providers.where(provider_code: args.map(&:upcase)) if args.any?

  MCB.pageable_output(MCB::Render::ActiveRecord.providers_table(providers, **opts))
end
