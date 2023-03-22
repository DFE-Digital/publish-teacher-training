# frozen_string_literal: true

module Find
  class CoursePreviewMissingInformationComponentPreview < ViewComponent::Preview
    def default
      render CoursePreview::MissingInformationComponent.new('Enter course summary', 'https://www.find-postgraduate-teacher-training.service.gov.uk/')
    end
  end
end
