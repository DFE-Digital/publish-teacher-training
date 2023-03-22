# frozen_string_literal: true

module Find
  class CoursePreviewMissingInformationComponentPreview < ViewComponent::Preview
    def default
      render Find::CoursePreviewMissingInformationComponent.new('Enter course summary', 'https://www.find-postgraduate-teacher-training.service.gov.uk/')
    end
  end
end
