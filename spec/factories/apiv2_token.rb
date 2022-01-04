require "ostruct"

# We only need this strategy here for the moment.
class JWTStrategy
  def association; end

  def result(evaluation)
    JWT.encode(
      data(evaluation),
      evaluation.object.secret,
      evaluation.object.algorithm,
    )
  end

  def data(evaluation)
    {
      data: evaluation.object.payload,
      **claims(evaluation),
    }
  end

  def claims(evaluation)
    now = evaluation.object.now
    {
      aud: evaluation.object.audience,
      exp: (now + 5.minutes).to_i,
      iat: now.to_i,
      iss: evaluation.object.issuer,
      sub: evaluation.object.subject,
    }
  end
end

FactoryBot.register_strategy(:build_jwt, JWTStrategy)

jwt = Struct.new(
  :payload,
  :secret,
  :algorithm,
  :audience,
  :issuer,
  :subject,
  :now,
)

FactoryBot.define do
  factory :apiv2, class: jwt do
    payload { nil }
    secret { Settings.authentication.secret }
    algorithm { Settings.authentication.algorithm }
    audience { Settings.authentication.audience }
    issuer { Settings.authentication.issuer }
    subject { Settings.authentication.subject }
    now { Time.zone.now }
  end
end
