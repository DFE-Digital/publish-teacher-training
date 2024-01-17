# frozen_string_literal: true

module Find
  module Courses
    module ContactDetailsComponent
      class View < ViewComponent::Base
        attr_reader :course

        delegate :provider, to: :course
        delegate :contact_form?, :contact_form, :show_address?, to: :course_information_config

        def initialize(course)
          super
          @course = course
        end

        def show_contact_form_instead_of_email?
          contact_form?
        end

        private

        def course_information_config
          @course_information_config ||= Configs::CourseInformation.new(course)
        end
      end
    end
  end
end
