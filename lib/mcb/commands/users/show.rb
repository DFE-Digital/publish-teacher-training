summary 'Show users info'
param :id
usage 'show <id>'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  user_id = args[:id]
  user = User.find(user_id)

  if user.nil?
    error "User not found: #{user_id}"
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
