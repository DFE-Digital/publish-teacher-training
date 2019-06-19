summary 'Attach a user to an organisation/provider in the DB. Will prompt to create user if email address is unknown.'
param :id_or_email_or_sign_in_id
param :provider_code, transform: ->(code) { code.upcase }
usage 'grant <id or email or sign-in id> <provider_code>'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  cli = HighLine.new
  provider = Provider.find_by!(provider_code: args[:provider_code])
  MCB::GrantAccessWizard.new(cli, args[:id_or_email_or_sign_in_id], provider).run
end
