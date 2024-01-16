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

        def show_contact_form_instead_of_email?
          course.provider.provider_code.in?(course_information_config(:contact_forms).keys.map(&:to_s))
        end

        def show_address?
          course.provider_code.in?(course_information_config(:show_address, :only_provider_codes)) && course.course_code.in?(course_information_config(:show_address, :only_course_codes))
        end

        def contact_form
          contact_forms[course.provider.provider_code]
        end

        private

        def contact_forms
          course_information_config(:contact_forms).stringify_keys
        end

        def course_information_config(*path)
          @course_information_config ||= Rails.application.config_for(:course_information)

          @course_information_config.dig(*path)
        end
      end
    end
  end
end
