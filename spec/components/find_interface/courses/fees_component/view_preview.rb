# frozen_string_literal: true

module FindInterface::Courses::FeesComponent
  class ViewPreview < ViewComponent::Preview
    def default
      render FindInterface::Courses::FeesComponent::View.new(mock_course)
    end

  private

    def mock_course
      FakeCourse.new(fee_uk_eu: "900000",
        fee_international: "999993393",
        cycle_range: "2022 to 2023",
        fee_details: "Other details")
    end

    class FakeCourse
      include ActiveModel::Model
      attr_accessor(:fee_uk_eu, :fee_international, :cycle_range, :fee_details)

      def enrichment_attribute(params)
        send(params)
      end
    end
  end
end
