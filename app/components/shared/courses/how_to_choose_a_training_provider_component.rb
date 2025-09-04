# frozen_string_literal: true

module Shared
  module Courses
    class HowToChooseATrainingProviderComponent < ViewComponent::Base
      attr_reader :course, :is_preview

      def initialize(course:, is_preview:)
        super
        @course = course
        @is_preview = is_preview
      end
    end
  end
end
