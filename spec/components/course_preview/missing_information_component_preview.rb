# frozen_string_literal: true

module CoursePreview
  class MissingInformationComponentPreview < ViewComponent::Preview
    %i[about_course
       degree
       fee_uk_eu
       gcse
       how_school_placements_work].each do |information_type|
      define_method information_type do
        provider = Provider.new(provider_code: 'BAT', recruitment_cycle: RecruitmentCycle.current)
        course = Course.new(provider:, course_code: '2KT')
        render CoursePreview::MissingInformationComponent.new(course:, information_type:)
      end
    end
  end
end
