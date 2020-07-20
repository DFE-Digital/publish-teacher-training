module NotificationService
  class CourseSubjectsUpdated
    include ServicePattern

    def initialize(
      course:,
      previous_subject_names:,
      updated_subject_names:,
      previous_course_name:,
      updated_course_name:
    )
      @course = course
      @previous_subject_names = previous_subject_names
      @updated_subject_names = updated_subject_names
      @previous_course_name = previous_course_name
      @updated_course_name = updated_course_name
    end

    def call
      return false unless notify_accredited_body?
      return false unless course.in_current_cycle?

      users = User.joins(:user_notifications).merge(UserNotification.course_update_notification_requests(course.accredited_body_code))

      users.each do |user|
        CourseSubjectsUpdatedEmailMailer.course_subjects_updated_email(
          course: course,
          previous_subject_names: previous_subject_names,
          updated_subject_names: updated_subject_names,
          previous_course_name: previous_course_name,
          updated_course_name: updated_course_name,
          recipient: user,
        ).deliver_later(queue: "mailer")
      end
    end

  private

    attr_reader :course, :updated_subject_names, :previous_subject_names, :previous_course_name, :updated_course_name

    def notify_accredited_body?
      return false if course.self_accredited?
      return false unless course.findable?

      true
    end
  end
end
