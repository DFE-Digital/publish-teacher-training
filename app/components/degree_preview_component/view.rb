# frozen_string_literal: true

module DegreePreviewComponent
  class View < ViewComponent::Base
    include PublishHelper

    attr_reader :course

    def initialize(course:)
      super
      @course = course
    end

  private

    def subject_name(course)
      case course.subjects.count
      when 1
        course.subjects.first.subject_name
      when 2
        "#{course.subjects.first.subject_name} or #{course.subjects.last.subject_name}"
      else
        course.name
      end
    end

    def degree_grade_content(course)
      {
        "two_one" => "An undergraduate degree at class 2:1 or above, or equivalent.",
        "two_two" => "An undergraduate degree at class 2:2 or above, or equivalent.",
        "third_class" => "An undergraduate degree, or equivalent. This should be an honours degree (Third or above), or equivalent.",
        "not_required" => "An undergraduate degree, or equivalent.",
      }[course.degree_grade]
    end
  end
end
