summary 'Attach a user to an organisation/provider in the DB'
param :provider_code, transform: ->(code) { code.upcase }
usage 'grant_access_to_provider <provider_code>'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  cli = HighLine.new
  provider = Provider.find_by!(provider_code: args[:provider_code])
  MCB::GrantAccessWizard.new(cli, provider).run
end
