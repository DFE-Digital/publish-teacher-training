# frozen_string_literal: true

module DegreeRowContentComponent
  class View < ViewComponent::Base
    attr_reader :course, :errors

    DEGREE_GRADE_MAPPING = {
      "two_one" => "2:1 or above, or equivalent",
      "two_two" => "2:2 or above, or equivalent",
      "third_class" => "Third class degree or above, or equivalent",
      "not_required" => "An undergraduate degree, or equivalent",
    }.freeze

    def initialize(course:, errors: nil)
      super
      @course = course
      @errors = errors
    end

    def inset_text_css_classes
      messages = errors&.values&.flatten

      if messages&.include?("Enter degree requirements")
        "app-inset-text--narrow-border app-inset-text--error"
      else
        "app-inset-text--narrow-border app-inset-text--important"
      end
    end

  private

    def degree_grade_content(course)
      DEGREE_GRADE_MAPPING[course.degree_grade]
    end
  end
end
