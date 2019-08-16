summary 'Attach a user to an organisation/provider in the DB. Will prompt to create user if email address is unknown.'
param :id_or_email_or_sign_in_id
option :p, 'provider_code', 'provider code',
       argument: :optional, transform: ->(code) { code.upcase }
flag nil, 'admin', 'admin'
usage 'grant --admin <user_id/email/sign_in_user_id> -p <provider_code>'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  cli = HighLine.new
  provider = nil
  admin = opts[:admin]
  if opts[:provider_code]
    provider = Provider.find_by!(provider_code: opts[:provider_code])
  end
  MCB::GrantAccessWizard.new(cli, args[:id_or_email_or_sign_in_id], provider, admin).run
end
