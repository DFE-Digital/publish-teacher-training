# frozen_string_literal: true

module Shared
  module Courses
    class HowToChooseATrainingProviderComponent < ViewComponent::Base
      attr_reader :course

      def initialize(course)
        super
        @course = course
      end
    end
  end
end
