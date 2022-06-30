# frozen_string_literal: true

module DegreeRowContentComponent
  class ViewPreview < ViewComponent::Preview
    [
      nil,
      "two_one",
      "two_two",
      "third_class",
      "not_required",
      "two_one",
    ].each do |degree_grade|
      define_method "degree_grade_is_#{degree_grade || 'nil'}" do
        provider = Provider.new(provider_code: "BAT", recruitment_cycle: RecruitmentCycle.current)
        course = Course.new(degree_grade:, provider:, course_code: "2KT")

        render(DegreeRowContentComponent::View.new(course: course.decorate))
      end
    end
  end
end
