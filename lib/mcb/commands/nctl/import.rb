summary 'import NCTL organisations info'
param :file

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  filename = args[:file]
  verbose "reading CSV file: #{filename}"
  import_csv = CSV.new(
    File.new(filename),
    headers: true,
    skip_lines: ',,.*'
  )

  import_csv.each do |row|
    nctl_org = NCTLOrganisation.find_by(nctl_id: row['nctl_id'].to_i)
    if nctl_org.nil?
      error "NCTL id not found: #{row['nctl_id']}"
    elsif row['URN'].present?
      nctl_org.update urn: row['URN'].to_i
    elsif row['UKPRN'].present?
      nctl_org.update ukprn: row['UKPRN'].to_i
    end
  end
end
