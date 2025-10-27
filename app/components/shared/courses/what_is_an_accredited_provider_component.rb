# frozen_string_literal: true

module Shared
  module Courses
    class WhatIsAnAccreditedProviderComponent < ViewComponent::Base
      attr_reader :course

      def initialize(course:)
        super
        @course = course
      end

      def render?
        course.accredited_provider_code.present? && course.accredited_provider_code != course.provider_code
      end
    end
  end
end
