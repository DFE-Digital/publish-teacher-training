# frozen_string_literal: true

module Find::Courses::QualificationsSummaryComponent
  class ViewPreview < ViewComponent::Preview
    def qts
      render Find::Courses::QualificationsSummaryComponent::View.new("QTS")
    end

    def pgce_with_qts
      render Find::Courses::QualificationsSummaryComponent::View.new("PGCE with QTS")
    end

    def pgde_with_qts
      render Find::Courses::QualificationsSummaryComponent::View.new("PGDE with QTS")
    end

    def pgce
      render Find::Courses::QualificationsSummaryComponent::View.new("PGCE")
    end

    def pgde
      render Find::Courses::QualificationsSummaryComponent::View.new("PGDE")
    end
  end
end
