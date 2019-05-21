summary 'List users in the tb'
usage 'list [<id1> <id2> <id3>...] where id is either user email, user ID or DfE-Sign-in ID'
flag :o, 'only-active-non-admins', 'Filter the user list to only active non-admin users for comms purposes'
option :c, 'csv-output-filename', 'Write the output to a CVS file at the given path', argument: :required

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  users = if args.any?
            args.map { |id| MCB.find_user_by_identifier id }
          elsif opts[:'only-active-non-admins']
            User.active.non_admins
          else
            User.all
          end

  headers = %i[id email sign_in_user_id first_name last_name last_login_date_utc]
  if opts[:'csv-output-filename']
    require 'csv'
    CSV.open(opts[:'csv-output-filename'], "wb") do |csv|
      csv << headers
      users.pluck(*headers).each { |user| csv << user }
    end
  else
    tp.set :capitalize_headers, false

    puts "\nUsers:"
    puts Tabulo::Table.new(users, *headers).pack(max_table_width: nil)
  end
end
