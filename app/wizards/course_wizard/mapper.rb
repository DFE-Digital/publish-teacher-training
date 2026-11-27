# frozen_string_literal: true

class CourseWizard
  # Seeds an edit of a saved course with the answers on the course's own
  # branch. A question that a change brings onto the path (for example the
  # student visa question after funding changes to fee) then starts blank,
  # so the user must answer it.
  #
  # Only the answers the funding type edit needs: the questions that decide
  # the path to funding type and the visa questions, and the funding and
  # visa answers themselves.
  class Mapper
    include DfE::Wizard::Mapper

    def to_answers(course)
      {
        level: course.level,
        qualification: course.qualification,
        funding_type: course.funding,
        accredited_provider_code: course.accredited_provider_code,
      }.merge(visa_answers(course)).compact
    end

  private

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
