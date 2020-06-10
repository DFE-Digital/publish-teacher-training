module Courses
  # Given a course has been created or updated
  # Create any missing UserNotification records
  # Remove any UserNotification records
  class AppendNotificationsService
    attr_reader :course

    def initialize(course:)
      # Course.where("accredited_body_code is not null").last.accrediting_provider.users
      @course = course
    end

    def call
      accredited_body_users.each do |user|
        if user.user_notifications.where(provider: provider).any?
          # notification preference exists, do nothing
        else
          other_notification = user.user_notifications.first

          if other_notification
            user.user_notifications.create!(provider: provider,
                                            course_update: other_notification.course_update,
                                            course_publish: other_notification.course_publish)
          end
        end
      end
    end

  private

    def accredited_body
      course.accrediting_provider
    end

    def provider
      course.provider
    end

    def accredited_body_users
      accredited_body.users
    end
  end
end
