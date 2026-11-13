# frozen_string_literal: true

class CourseWizard
  # Maps a saved course to the answers an edit of it starts from, and the
  # edit's answers back to course attributes.
  class Mapper
    ATTRIBUTES = {
      funding_type: :funding,
      can_sponsor_student_visa: :can_sponsor_student_visa,
      can_sponsor_skilled_worker_visa: :can_sponsor_skilled_worker_visa,
    }.freeze

    # The course's own answers to the questions that decide the path to
    # funding type and the visa questions, and its funding and visa answers.
    # A question that a change brings onto the path (the student visa
    # question after funding changes to fee, say) starts blank, so the user
    # must answer it.
    def to_answers(course)
      {
        level: course.level,
        qualification: course.qualification,
        funding_type: course.funding,
        accredited_provider_code: course.accredited_provider_code,
      }.merge(visa_answers(course)).compact
    end

    # The course attributes the answers set. A deadline on the same date as
    # the course's is not a change, whatever its time of day.
    def to_attributes(answers, course)
      attributes = answers.slice(*ATTRIBUTES.keys).transform_keys(ATTRIBUTES)
      return attributes unless answers.key?(:visa_sponsorship_application_deadline_required)

      deadline = deadline_from(answers)
      attributes[:visa_sponsorship_application_deadline_at] = deadline unless deadline&.to_date == course.visa_sponsorship_application_deadline_at&.to_date
      attributes
    end

  private

    def deadline_from(answers)
      return unless ActiveModel::Type::Boolean.new.cast(answers[:visa_sponsorship_application_deadline_required])

      Draft::DateParts.parse(answers[:visa_sponsorship_application_deadline_at])&.to_date&.in_time_zone&.end_of_day
    end

    def visa_answers(course)
      return {} if course.further_education_course?

      sponsors = course.fee? ? course.can_sponsor_student_visa : course.can_sponsor_skilled_worker_visa
      answers = course.fee? ? { can_sponsor_student_visa: sponsors } : { can_sponsor_skilled_worker_visa: sponsors }
      return answers unless sponsors

      deadline = course.visa_sponsorship_application_deadline_at
      answers.merge(
        visa_sponsorship_application_deadline_required: deadline.present?,
        visa_sponsorship_application_deadline_at: Draft::DateParts.parse(deadline),
      )
    end
  end
end
