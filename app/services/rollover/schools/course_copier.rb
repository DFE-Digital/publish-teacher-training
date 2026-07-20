# frozen_string_literal: true

module Rollover
  module Schools
    class CourseCopier
      def call(course:, new_provider:, new_course:)
        course.schools.includes(:provider_school).find_each do |course_school|
          new_provider_school = new_provider.schools.find_by!(
            uuid: course_school.provider_school.uuid,
          )

          new_course.schools.find_or_create_by!(provider_school: new_provider_school) do |new_course_school|
            new_course_school.gias_school_id = new_provider_school.gias_school_id
            new_course_school[:site_code] = new_provider_school.site_code if new_course_school.has_attribute?(:site_code)
          end
        end
      end
    end
  end
end
