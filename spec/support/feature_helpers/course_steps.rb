# frozen_string_literal: true

module FeatureHelpers
  module CourseSteps
    attr_reader :course

    def given_a_course_exists(*traits, **overrides)
      @course ||= create(:course, *traits, **overrides, provider: current_user.providers.first)
    end
  end
end
