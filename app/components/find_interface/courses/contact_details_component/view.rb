module FindInterface
  module Courses
    class ContactDetailsComponent::View < ViewComponent::Base
      attr_reader :course

      delegate :provider, to: :course

      def initialize(course)
        super
        @course = course
      end
    end
  end
end
