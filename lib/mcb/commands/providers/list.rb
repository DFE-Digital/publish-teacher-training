name 'list'
usage 'list [<code>...]'
summary 'List providers in db'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  recruitment_cycle = MCB.get_recruitment_cycle(opts)

  providers = recruitment_cycle.providers
  providers = providers.where(provider_code: args.map(&:upcase)) if args.any?

  output = [
    'Providers:',
    Tabulo::Table.new(providers) { |t|
      t.add_column :id
      t.add_column(:provider_code)
      t.add_column :provider_name
      t.add_column :provider_type
    }.pack(max_table_width: nil)
  ]

  MCB.pageable_output(output)
end
