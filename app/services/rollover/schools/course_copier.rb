# frozen_string_literal: true

module Rollover
  module Schools
    class CourseCopier
      def call(course:, new_provider:, new_course:)
        course.schools.includes(:provider_school).find_each do |course_school|
          new_provider_school = new_provider.schools.find_by!(
            gias_school_id: course_school.provider_school.gias_school_id,
            site_code: course_school.provider_school.site_code,
          )

          new_course.schools.find_or_create_by!(provider_school: new_provider_school) do |new_course_school|
            new_course_school.gias_school_id = new_provider_school.gias_school_id
          end
        end
      end
    end
  end
end
