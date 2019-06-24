summary 'map missing UKPRNs using URNs on NCTL organisations'

# the EDUBASE/Get Info About Schools CSV file which contains URN and UKPRN info
# see https://get-information-schools.service.gov.uk/Downloads
param :file

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  filename = args[:file]
  verbose "reading CSV file: #{filename}"

  require 'csv'
  schools_data = CSV.read(filename, encoding: 'windows-1251:utf-8', headers: true)
  urn_to_ukprn_mapping = schools_data.inject({}) do |memo, row|
    memo[row["URN"]] = row["UKPRN"]
    memo
  end

  NCTLOrganisation.where(ukprn: nil).each do |nctl_organisation|
    ukprn = urn_to_ukprn_mapping[nctl_organisation.urn.to_s]
    if ukprn.present?
      nctl_organisation.update(ukprn: ukprn)
    else
      puts "Cannot map #{nctl_organisation.urn}"
    end
  end
end
