# frozen_string_literal: true

module Find
  module Courses
    module ApplyComponent
      class View < ViewComponent::Base
        attr_reader :course, :preview, :utm_content

        delegate :application_status_open?, :provider, to: :course

        def initialize(course, preview: false, utm_content: nil)
          super()
          @course = course
          @preview = preview
          @utm_content = utm_content
        end

        def apply_path
          return find_apply_destination_path unless preview

          apply_publish_provider_recruitment_cycle_course_path(provider_code: course.provider.provider_code, code: course.course_code, recruitment_cycle_year: provider.recruitment_cycle.year)
        end

        def show_application_deadline?
          course.visa_sponsorship_application_deadline_at.present?
        end

        def application_deadline
          course.visa_sponsorship_application_deadline_at.to_fs(:govuk_date)
        end

      private

        def find_confirm_apply_path?
          return false if school_experience_interstitial_path?

          FeatureFlag.active?(:candidate_accounts)
        end

        def school_experience_interstitial_path?
          course.show_school_experience?
        end

        def find_apply_destination_path
          if school_experience_interstitial_path?
            find_school_experience_interstitial_path(
              provider_code: course.provider.provider_code,
              course_code: course.course_code,
            )
          elsif find_confirm_apply_path?
            find_confirm_apply_path(
              provider_code: course.provider.provider_code,
              course_code: course.course_code,
            )
          else
            find_apply_path(
              provider_code: course.provider.provider_code,
              course_code: course.course_code,
            )
          end
        end
      end
    end
  end
end
