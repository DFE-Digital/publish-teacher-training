# frozen_string_literal: true

module Find
  module Courses
    module ContactDetailsComponent
      class View < ViewComponent::Base
        attr_reader :course, :preview

        delegate :provider, to: :course
        delegate :contact_form?, :contact_form, :show_address?, to: :course_information_config

        def initialize(course, preview: false)
          super()
          @course = course
          @preview = preview
        end

        def show_contact_form_instead_of_email?
          contact_form?
        end

        def website_url
          if preview
            provider.decorate.website
          else
            find_track_click_path(url: find_provider_website_path(course.provider_code, course.course_code))
          end
        end

      private

        def course_information_config
          @course_information_config ||= Configs::CourseInformation.new(course)
        end
      end
    end
  end
end
