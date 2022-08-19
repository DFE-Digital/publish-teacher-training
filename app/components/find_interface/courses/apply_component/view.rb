module FindInterface
  module Courses
    class ApplyComponent::View < ViewComponent::Base
      attr_reader :course

      delegate :has_vacancies?, :provider, to: :course

      def initialize(course)
        super
        @course = course
      end
    end
  end
end
