# frozen_string_literal: true

module API
  module Public
    module V1
      module Providers
        class CoursesController < ApplicationController
          def index
            render jsonapi: paginate(courses),
                   include: include_param,
                   meta: { count: courses.count("course.id") },
                   class: API::Public::V1::SerializerService.call
          end

          def show
            render jsonapi: course,
                   include: include_param,
                   class: API::Public::V1::SerializerService.call
          end

        private

          def courses
            @courses ||= APICourseSearchService.call(filter: params[:filter],
                                                     course_scope: provider.courses)
          end

          def course
            @course ||= provider.courses.find_by!(course_code: params[:code])
          end

          def provider
            @provider ||= recruitment_cycle.providers.find_by!(provider_code: params[:provider_code])
          end

          def include_param
            params.fetch(:include, "")
          end
        end
      end
    end
  end
end
