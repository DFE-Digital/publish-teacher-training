# frozen_string_literal: true

module NotificationService
  class CourseWithdrawn
    include ServicePattern

    def initialize(course:)
      @course = course
    end

    def call
      return false unless notify_accredited_provider?
      return false unless course.in_current_cycle?

      users.each do |user|
        CourseWithdrawEmailMailer.course_withdraw_email(
          course,
          user,
          DateTime.now
        ).deliver_later
      end
    end

    private

    attr_reader :course

    def users
      User.course_publish_subscribers(course.accredited_provider_code)
    end

    def notify_accredited_provider?
      return false if course.self_accredited?

      true
    end
  end
end
