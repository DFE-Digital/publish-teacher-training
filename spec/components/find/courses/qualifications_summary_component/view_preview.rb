# frozen_string_literal: true

module Find
  module Courses
    module QualificationsSummaryComponent
      class ViewPreview < ViewComponent::Preview
        def qts
          course = Course.new(qualification: "qts").decorate
          render Find::Courses::QualificationsSummaryComponent::View.new(course:)
        end

        def pgce_with_qts
          course = Course.new(qualification: "pgce_with_qts").decorate
          render Find::Courses::QualificationsSummaryComponent::View.new(course:)
        end

        def pgde_with_qts
          course = Course.new(qualification: "pgde_with_qts").decorate
          render Find::Courses::QualificationsSummaryComponent::View.new(course:)
        end

        def pgce
          course = Course.new(qualification: "pgce").decorate
          render Find::Courses::QualificationsSummaryComponent::View.new(course:)
        end

        def pgde
          course = Course.new(qualification: "pgde").decorate
          render Find::Courses::QualificationsSummaryComponent::View.new(course:)
        end
      end
    end
  end
end
