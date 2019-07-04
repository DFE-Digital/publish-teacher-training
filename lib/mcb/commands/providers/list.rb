name 'list'
summary 'List providers in db'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  providers = if args.any?
                Provider.where(provider_code: args.to_a.map(&:upcase))
              else
                Provider.all
              end

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
