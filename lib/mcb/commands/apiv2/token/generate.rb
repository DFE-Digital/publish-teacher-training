name "generate"
summary "Generate a JWT token using the secret"
usage "generate [options] <code>"
param :email
option :S, :secret, "the JWT secret",
       argument: :required
option nil, :encoding, "the encoding to use for the JWT",
       argument: :required,
       default: "HS256"
option nil, :audience, "the audience to use for the JWT",
       argument: :required
option nil, :issuer, "the issuer to use for the JWT",
       argument: :required
option nil, :subject, "the subject to use for the JWT",
       argument: :required

run do |opts, args, _cmd|
  encoding = opts[:encoding]
  secret   = opts[:secret]
  audience = opts[:audience]
  issuer = opts[:issuer]
  subject = opts[:subject]

  email = args[:email]
  token = MCB.generate_apiv2_token(
    email: email,
    encoding: encoding,
    secret: secret,
    audience: audience,
    issuer: issuer,
    subject: subject,
  )

  puts token
end
