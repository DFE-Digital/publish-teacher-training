name "generate"
summary "Generate a JWT token using the secret"
usage "generate [options] <code>"
param :email
option :S, :secret, "the JWT secret",
       argument: :required
option nil, :encoding, "the encoding to use for the JWT",
       argument: :required,
       default: "HS256"


run do |opts, args, _cmd|
  encoding = opts[:encoding]
  secret   = opts[:secret]

  email = args[:email]
  token = MCB.generate_apiv2_token(
    email: email,
    encoding: encoding,
    secret: secret,
  )

  puts token
end
