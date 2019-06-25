summary 'Generate allocation reports for a given NCTL ID'
usage 'generate_allocations_report <template path> <nctl ID>'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  template_path = File.expand_path(args[0])
  verbose "template: #{template_path}"

  nctl_id = args[1]
  nctl_organisations = nctl_id.present? ? NCTLOrganisation.where(nctl_id: nctl_id) : NCTLOrganisation.all

  nctl_organisations.each do |nctl_organisation|
    puts "Generating allocations report for #{nctl_organisation}"
    nctl_organisation.save_allocations_report(template_path)
  end
end
