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
class UserNotification < ApplicationRecord
  belongs_to :user,
             inverse_of: :user_notifications

  belongs_to :provider,
             foreign_key: :provider_code,
             primary_key: :provider_code,
             inverse_of: :user_notifications

  validates :course_create, :course_update, inclusion: { in: [true, false] }

  scope :course_create_notification_requests, ->(provider_code) do
    where(provider_code: provider_code, course_create: true)
  end

  scope :course_update_notification_requests, ->(provider_code) do
    where(provider_code: provider_code, course_update: true)
  end

  scope :find_or_initialize, ->(provider_code) do
    existing_notification = find_by(provider_code: provider_code)

    existing_notification || new(provider_code: provider_code)
  end
end
