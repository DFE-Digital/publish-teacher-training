name 'generate'
summary 'Generate a JWT token using the secret'
usage 'generate [options] <code>'
param :email
option :S, 'secret', 'the JWT secret', argument: :required


run do |opts, args, _cmd|
  require 'jwt'
  payload = { email: args[:email] }
  token = JWT.encode(payload, opts[:secret], 'HS256')

  puts "Token: #{token}"
end
