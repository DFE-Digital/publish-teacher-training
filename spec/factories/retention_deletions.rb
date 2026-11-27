# frozen_string_literal: true

FactoryBot.define do
  factory :retention_deletion do
    entity_type { "candidate" }
    sequence(:entity_id, &:to_s)
    deleted_records { { "candidate" => [entity_id], "saved_course" => %w[456 457] } }
    deleted_at { Time.current }
  end
end
