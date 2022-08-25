# frozen_string_literal: true

module FindInterface::Courses::QualificationsSummaryComponent
  class ViewPreview < ViewComponent::Preview
    def qts
      render FindInterface::Courses::QualificationsSummaryComponent::View.new("QTS")
    end

    def pgce_with_qts
      render FindInterface::Courses::QualificationsSummaryComponent::View.new("PGCE with QTS")
    end

    def pgde_with_qts
      render FindInterface::Courses::QualificationsSummaryComponent::View.new("PGDE with QTS")
    end

    def pgce
      render FindInterface::Courses::QualificationsSummaryComponent::View.new("PGCE")
    end

    def pgde
      render FindInterface::Courses::QualificationsSummaryComponent::View.new("PGDE")
    end
  end
end
