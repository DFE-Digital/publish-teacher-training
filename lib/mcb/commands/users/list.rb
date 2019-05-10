summary 'List users in the tb'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  users = if args.any?
            User.where(id: args.to_a)
          else
            User.all
          end

  tp.set :capitalize_headers, false

  puts "\nUsers:"
  tp users, 'id', 'email', 'first_name', 'last_name', 'last_login_date_utc'
end
