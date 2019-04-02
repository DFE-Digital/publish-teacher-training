# == Schema Information
#
# Table name: course_enrichment
#
#  id                           :integer          not null, primary key
#  created_by_user_id           :integer
#  created_at                   :datetime         not null
#  provider_code                :text             not null
#  json_data                    :jsonb
#  last_published_timestamp_utc :datetime
#  status                       :integer          not null
#  ucas_course_code             :text             not null
#  updated_by_user_id           :integer
#  updated_at                   :datetime         not null
#

FactoryBot.define do
  factory :course_enrichment do
    sequence(:provider_code) { |n| "A#{n}" }
    sequence(:ucas_course_code) { |n| "C#{n}D3" }
    status { :draft }
  end

  trait :initial_draft do
    last_published_timestamp_utc { nil }
  end

  trait :published do
    status { :published }
    last_published_timestamp_utc { 5.days.ago }
  end

  trait :subsequent_draft do
    status { :draft }
    last_published_timestamp_utc { 5.days.ago }
  end
end
