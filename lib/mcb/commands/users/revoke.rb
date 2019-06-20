summary 'Remove a user from an organisation/provider in the DB.'
param :id_or_email_or_sign_in_id
param :provider_code, transform: ->(code) { code.upcase }
usage 'revoke <user_id/email/sign_in_user_id> <provider_code>'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  cli = HighLine.new
  provider = Provider.find_by!(provider_code: args[:provider_code])
  MCB::RevokeAccessWizard.new(cli, args[:id_or_email_or_sign_in_id], provider).run
end
