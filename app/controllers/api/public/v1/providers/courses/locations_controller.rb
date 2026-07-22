# frozen_string_literal: true

module API
  module Public
    module V1
      module Providers
        module Courses
          class LocationsController < API::Public::V1::ApplicationController
            def index
              render jsonapi: locations,
                     include: include_param,
                     expose: exposures,
                     meta:,
                     class: API::Public::V1::SerializerService.call
            end

          private

            # has_course_schools tells API consumers whether the returned
            # locations are the course's own attached schools (true) or the
            # provider's schools we fell back to because the course is exempt
            # from needing schools and has none of its own (false).
            def meta
              return unless schools_remodelled

              { has_course_schools: course&.schools.present? }
            end

            def locations
              @locations ||= if schools_remodelled
                               remodelled_locations
                             else
                               course&.sites
                             end
            end

            # A course that support has approved to publish without schools
            # attached falls back to its provider's schools when it has none of
            # its own; every other course only ever serves its own attached
            # schools.
            def remodelled_locations
              return unless course

              return course.schools unless ::Courses::PublishRules::SchoolPresenceExemption.applies?(course)

              course.schools.presence || provider.schools.includes(:gias_school)
            end

            # On the schools path each Course::School serializes its own
            # SchoolLocationStatus, so there is no site_statuses collection to
            # expose (and reading course.site_statuses would query the legacy
            # course_site table for nothing).
            def exposures
              return { course: } if schools_remodelled

              { course:, location_statuses: }
            end

            def location_statuses
              @location_statuses ||= course&.site_statuses
            end

            def course
              @course ||= if schools_remodelled
                            provider.courses.includes(schools: %i[gias_school provider_school]).find_by(course_code: params[:course_code])
                          else
                            provider.courses.includes(site_statuses: [:site]).find_by(course_code: params[:course_code])
                          end
            end

            def provider
              @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
            end

            def include_param
              params.fetch(:include, "")
            end

            def schools_remodelled
              FeatureFlag.active?(:course_publishing_uses_new_school_model) && recruitment_cycle.after?(Settings.schools_remodel_cycle_year)
            end
          end
        end
      end
    end
  end
end
