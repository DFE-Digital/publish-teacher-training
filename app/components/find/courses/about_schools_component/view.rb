# frozen_string_literal: true

module Find
  module Courses
    module AboutSchoolsComponent
      class View < ViewComponent::Base
        include PublishHelper
        include PreviewHelper

        attr_reader :course

        delegate :published_how_school_placements_work,
                 :program_type,
                 :study_sites,
                 :site_statuses, to: :course

        def initialize(course)
          super
          @course = course
        end

        def render?
          published_how_school_placements_work.present? ||
            program_type.in?(%w[higher_education_programme scitt_programme]) ||
            study_sites.any? ||
            site_statuses.map(&:site).uniq.many? || preview?(params)
        end

        def show_higher_education_guidance?
          return false unless course.higher_education_programme?

          course_information_config(:higher_education, :except_provider_codes).exclude?(course.provider.provider_code)
        end

        def show_scitt_guidance?
          return false unless course.scitt_programme?

          course_information_config(:scitt_programmes, :except_provider_codes).exclude?(course.provider_code)
        end

        private

        def course_information_config(*path)
          @course_information_config ||= Rails.application.config_for(:course_information)

          @course_information_config.dig(:where_you_will_train, *path)
        end
      end
    end
  end
end
