summary 'Generate allocation reports for a given NCTL ID'
param :template_path
param :nctl_id

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  nctl_id = args[:nctl_id]
  verbose "processing NCTL ID: #{nctl_id}"

  template_path = File.expand_path(args[:template_path])
  verbose "template: #{template_path}"

  nctl_organisation = NCTLOrganisation.find_by!(nctl_id: nctl_id)

  puts "Generating allocations report for #{nctl_organisation.name}"
  nctl_organisation.save_allocations_report(template_path)
  if nctl_organisation.accredited_body?
    puts "Generating allocations for orgs accredited by #{nctl_organisation.name}"
    nctl_organisation.save_allocations_report(template_path, "accredited-by-#{nctl_organisation.ukprn}", type: :accredited_body)
  end
end
