# frozen_string_literal: true

module CoursePreview
  class MissingInformationComponentPreview < ViewComponent::Preview
    %i[about_this_course
       degree
       fee_uk_eu
       gcse
       how_school_placements_work
       train_with_disability
       train_with_us
       about_accrediting_provider].each do |information_type|
      define_method information_type do
        provider = Provider.new(provider_code: 'BAT', recruitment_cycle: RecruitmentCycle.current)
        accrediting_provider = Provider.new(provider_code: 'CAT', recruitment_cycle: RecruitmentCycle.current)
        course = Course.new(provider:, course_code: '2KT', accrediting_provider:)
        render CoursePreview::MissingInformationComponent.new(course:, information_type:, is_preview: true)
      end
    end
  end
end
