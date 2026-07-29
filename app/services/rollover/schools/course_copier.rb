# frozen_string_literal: true

module Rollover
  module Schools
    class CourseCopier
      def call(course:, new_provider:, new_course:)
        lookup = new_provider_schools(new_provider)
        existing = new_course.schools.index_by(&:provider_school_id)

        course.schools.with_available_gias_school.includes(:provider_school).find_each do |course_school|
          old_provider_school = course_school.provider_school
          new_provider_school = lookup[[old_provider_school.gias_school_id, old_provider_school.site_code]]

          if new_provider_school.nil?
            raise ActiveRecord::RecordNotFound,
                  "Couldn't find Provider::School for provider #{new_provider.id} " \
                  "with gias_school_id #{old_provider_school.gias_school_id} " \
                  "and site_code #{old_provider_school.site_code}"
          end

          next if existing.key?(new_provider_school.id)

          existing[new_provider_school.id] = new_course.schools.create!(
            provider_school: new_provider_school,
            gias_school_id: new_provider_school.gias_school_id,
          )
        end
      end

    private

      # Every school belonging to the new provider is created before any course
      # is copied, so load them once per provider rather than once per course.
      def new_provider_schools(new_provider)
        @new_provider_schools ||= {}
        @new_provider_schools[new_provider.id] ||=
          new_provider.schools.index_by { |school| [school.gias_school_id, school.site_code] }
      end
    end
  end
end
