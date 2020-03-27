# == Schema Information
#
# Table name: user_notification
#
#  course_create :boolean          default(FALSE)
#  course_update :boolean          default(FALSE)
#  created_at    :datetime         not null
#  id            :bigint           not null, primary key
#  provider_code :string           not null
#  updated_at    :datetime         not null
#  user_id       :integer          not null
#
# Indexes
#
#  index_user_notification_on_provider_code  (provider_code)
#
FactoryBot.define do
  factory :user_notification do
    association :user
    association :provider
  end
end
