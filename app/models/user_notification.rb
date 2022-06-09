class UserNotification < ApplicationRecord
  belongs_to :user,
    inverse_of: :user_notifications

  belongs_to :provider,
    foreign_key: :provider_code,
    primary_key: :provider_code,
    inverse_of: :user_notifications

  validates :course_publish, :course_update, inclusion: { in: [true, false] }

  scope :course_publish_notification_requests, lambda { |provider_code|
    where(provider_code: provider_code, course_publish: true)
  }

  scope :course_update_notification_requests, lambda { |provider_code|
    where(provider_code: provider_code, course_update: true)
  }
end
