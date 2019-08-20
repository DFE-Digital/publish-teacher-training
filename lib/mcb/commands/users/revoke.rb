summary 'Remove a user from an organisation/provider in the DB.'
param :id_or_email_or_sign_in_id
option :p, 'provider_code', 'provider code',
       argument: :optional, transform: ->(code) { code.upcase }
usage 'revoke <user_id/email/sign_in_user_id> [--provider_code <provider_code>]'

run do |opts, args, _cmd|
  MCB.init_rails(opts)
  cli = HighLine.new

  provider = Provider.find_by(provider_code: opts[:provider_code])
  user = MCB.find_user_by_identifier args[:id_or_email_or_sign_in_id]

  if user == nil
    puts "#{args[:id_or_email_or_sign_in_id]} does not exist."
  else
    MCB::RevokeAccessWizard.new(cli, user, provider).run
  end
end
