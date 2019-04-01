require 'ostruct'

# We only need this strategy here for the moment.
class JWTStrategy
  def association; end

  def result(evaluation)
    JWT.encode evaluation.object.payload,
               evaluation.object.secret,
               evaluation.object.algorithm
  end
end

FactoryBot.register_strategy(:build_jwt, JWTStrategy)

FactoryBot.define do
  factory :apiv2, class: OpenStruct do
    secret    { Settings.authentication.secret }
    algorithm { Settings.authentication.algorithm }
    email     { 'foobar@localhost' }
    payload   { { email: email } }
  end
end
