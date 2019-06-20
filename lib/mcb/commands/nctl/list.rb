name 'list'
summary 'List NCTL organisations in db'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  nctl_organisations = if args.any?
                         NCTLOrganisation.where(nctl_organisation: args)
                       else
                         NCTLOrganisation.all
                       end

  puts MCB::Render::ActiveRecord.nctl_organisations_table nctl_organisations
end
