# frozen_string_literal: true

module Find
  module Courses
    module ContactDetailsComponent
      class View < ViewComponent::Base
        attr_reader :course

        delegate :provider, to: :course

        def initialize(course)
          super
          @course = course
        end

        def show_address?
          course.provider_code.in?(course_information_config(:only_provider_codes)) && course.course_code.in?(course_information_config(:only_course_codes))
        end

        def course_information_config(*path)
          Rails.application.config_for(:course_information).dig(:show_address, *path)
        end
      end
    end
  end
end
