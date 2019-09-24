if ENV.key?("MCB_AUDIT_USER")
  user = User.find_by email: ENV["MCB_AUDIT_USER"]

  raise "Could not find user by email: #{ENV['MCB_AUDIT_USER']}" unless user

  puts "Audit user: #{user}"
  Audited.store[:audited_user] = user
end
