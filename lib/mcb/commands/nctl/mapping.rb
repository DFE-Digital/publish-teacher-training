summary 'generate provider to nctl organisation mapping'

option :c, :csv, 'Generate CSV'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  providers = Hash.new do |h, k|
    h[k] = {
      provider_to_nctl_organisation: [],
      nctl_organisation_to_provider: []
    }
  end

  Provider.includes(:organisations).all.each do |p|
    providers[p][:provider_to_nctl_organisation] = p.organisation&.nctl_organisation_for(p) || [] 
  end

  NCTLOrganisation.includes(organisation: :providers).all.each do |no|
    no.organisation.providers.each do |p|
      providers[p][:nctl_organisation_to_provider] << no
    end
  end

  rows = providers.map do |p, d|
    code = p.provider_code
    provider_to_nctl = d[:provider_to_nctl_organisation].sort
    nctl_to_provider = d[:nctl_organisation_to_provider].sort

    nctl_matches = provider_to_nctl.any? && provider_to_nctl == nctl_to_provider
    matching_nctls = provider_to_nctl & nctl_to_provider

    [
      p,
      fixed_mappings[code],
      fixed_mappings[code] && (Array(fixed_mappings[code]) == provider_to_nctl.map(&:nctl_id)),
      provider_to_nctl&.join(","),
      fixed_mappings[code] && (Array(fixed_mappings[code]) == nctl_to_provider.map(&:nctl_id)),
      nctl_to_provider&.join(", "),
      (nctl_matches ? 'Yes' : 'No'),
      matching_nctls.join(', '),
    ]
  end

  if opts[:csv]
    csv = CSV.generate do |csv|
      csv << [
        'Provider',
        'Mapped NCTL',
        'Correct',
        'provider -> NCTL Organisation',
        'Correct',
        'NCTL Organisation -> provider',
        'Matches?',
        'Matches'
      ]
      rows.each { |row| csv << row }
    end

    puts csv
  else
    puts Terminal::Table.new(rows: rows)
  end
end

def fixed_mappings
  @fixed_mappings ||= Hash[CSV.parse(<<~EOCSV).map(&:reverse)]
    11248,1LN
    11449,153
    13610,1FG
    10532,2CJ
    10532,2CG
    10532,2CK
    10532,2CL
    10532,2CH
    10532,15W
    10532,2CF
    10817,2D1
    10962,2GQ
    11017,1ED
    11829,1Z4
    11067,1V9
    10477,1AJ
    10979,1AY
    11200,1UR
    11080,28A
    11080,1T7
    10073,1B7
    11651,1K9
    11368,13O
    10929,2GJ
    10069,1RC
    10724,2BQ
    11216,2K4
    10142,219
    12055,2K7
    10466,186
    5650,25E
    5568,L26
    1532,L24
    12037,1F9
    10009,1ZY
    12037,1VA
    10009,1VA
    10950,2G9
    11267,1GV
    10373,2JN
    11261,1T2
    10320,1CV
    11305,2H3
    11305,1EL
    11305,2BV
    13615,1V7
    11077,2LC
    11207,27F
    11207,2KC
    10849,2DO
    10849,16E
    11156,1NP
    11156,2KQ
    11296,2J5
    11296,264
    11162,2KP
    11162,27C
    5616,K51
    5616,1S2
    11170,1R1
    11220,2K2
  EOCSV
end


