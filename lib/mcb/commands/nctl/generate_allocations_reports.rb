summary 'Generate allocation reports for a given NCTL ID'
param :nctl_id

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  nctl_id = args[:nctl_id]
  verbose "processing NCTL ID: #{nctl_id}"

  nctl_organisation = NCTLOrganisation.find_by!(nctl_id: nctl_id)

  puts "Generating allocations report for #{nctl_organisation.name}"
  nctl_organisation.save_allocations_report
  if nctl_organisation.accredited_body?
    puts "Generating allocations for orgs accredited by #{nctl_organisation.name}"
    nctl_organisation.save_allocations_report("accredited-by-#{nctl_id}", type: :accredited_body)
  end
end
