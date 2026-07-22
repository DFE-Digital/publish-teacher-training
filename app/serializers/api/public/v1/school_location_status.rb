# frozen_string_literal: true

module API
  module Public
    module V1
      class SchoolLocationStatus
        def initialize(course_school)
          @course_school = course_school
        end

        # All SchoolLocationStatus are running and published.
        # These values are included to maintain consistency with the Site and
        # SiteStatus models until we can deprecate these in the API
        COURSE_RUNNING_STATUS = "running"
        COURSE_PUBLISHED_STATUS = "published"

        delegate :id, to: :@course_school

        def status
          COURSE_RUNNING_STATUS
        end

        def publish
          COURSE_PUBLISHED_STATUS
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
