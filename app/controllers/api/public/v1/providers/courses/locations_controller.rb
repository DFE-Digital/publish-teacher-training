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
                expose: { course:, location_statuses: },
                class: API::Public::V1::SerializerService.call
            end

            private

            def locations
              @locations ||= course&.sites
            end

            def location_statuses
              @location_statuses ||= course&.site_statuses
            end

            def course
              @course ||= provider.courses.includes(site_statuses: [:site]).find_by(course_code: params[:course_code])
            end

            def provider
              @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
            end

            def recruitment_cycle
              @recruitment_cycle ||= RecruitmentCycle.find_by(year: params[:recruitment_cycle_year])
            end

            def include_param
              params.fetch(:include, '')
            end
          end
        end
      end
    end
  end
end
