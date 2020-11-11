require "ostruct"

# We only need this strategy here for the moment.
class JWTStrategy
  def association; end

  def result(evaluation)
    JWT::EncodeService.call(payload: evaluation.object.payload)
  end
end

FactoryBot.register_strategy(:build_jwt, JWTStrategy)

FactoryBot.define do
  factory :apiv2, class: OpenStruct do
    payload {}
  end
end
