# frozen_string_literal: true

module InternationalStudentsPreview
  class ViewPreview < ViewComponent::Preview
    def default
      provider = Provider.new(provider_code: "BAT", recruitment_cycle: RecruitmentCycle.current, can_sponsor_student_visa: false)
      course = CourseDecorator.new(Course.new(provider:, course_code: "2KT", funding_type: "fee"))
      render InternationalStudentsPreview::View.new(course:)
    end
  end
end
