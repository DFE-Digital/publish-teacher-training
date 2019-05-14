summary 'Show users info'
param :id_or_email_or_sign_in_id
usage 'show <id or email or sign-in id>'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  user = MCB.find_user_by_identifier args[:id_or_email_or_sign_in_id]
  if user.nil?
    error "User not found: #{args[:id_or_email_or_sign_in_id]}"
  else
    puts "User:"
    puts Terminal::Table.new rows: user.attributes
    puts ''
    puts "Providers:"
    puts Tabulo::Table.new(user.providers,
                           :id,
                           :provider_name,
                           :provider_code).pack
  end
end
