# frozen_string_literal: true

module NotificationService
  class CourseSubjectsUpdated
    include ServicePattern

    def initialize(
      course:,
      previous_subject_names:,
      previous_course_name:
    )
      @course = course
      @previous_subject_names = previous_subject_names
      @previous_course_name = previous_course_name
    end

    def call
      return false unless notify_accredited_provider?
      return false unless course.in_current_cycle?

      users.each do |user|
        CourseSubjectsUpdatedEmailMailer.course_subjects_updated_email(
          course:,
          previous_subject_names:,
          previous_course_name:,
          recipient: user,
        ).deliver_later
      end
    end

  private

    attr_reader :course, :previous_subject_names, :previous_course_name

    def users
      User.course_update_subscribers(course.accredited_provider_code)
    end

    def notify_accredited_provider?
      return false if course.self_accredited?
      return false unless course.findable?

      true
    end
  end
end
