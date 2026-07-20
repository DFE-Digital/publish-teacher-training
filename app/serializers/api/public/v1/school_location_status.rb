# frozen_string_literal: true

module API
  module Public
    module V1
      class SchoolLocationStatus
        def initialize(course_school)
          @course_school = course_school
        end

        delegate :id, to: :@course_school

        def status
          "running"
        end

        def publish
          "published"
        end

        def vac_status
          SiteStatus.default_vac_status_given(study_mode: @course_school.course.study_mode).to_s
        end

        def has_vacancies?
          true
        end
      end
    end
  end
end
