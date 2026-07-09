module Publish
  module Schools
    # Renders the "Placement/Employing schools" value on a course's basic details
    # summary list. Shows the list inline for a handful of schools, but collapses
    # it into a GOV.UK details component (with the count as the summary link) once
    # there are more than SCHOOLS_DETAILS_THRESHOLD, so long lists are less
    # prominent and easier to scan.
    class AttachedSchoolsSummaryComponent < ViewComponent::Base
      SCHOOLS_DETAILS_THRESHOLD = 5

      attr_reader :course

      def initialize(course:)
        super()

        @course = course
      end

      def school_names
        @school_names ||= course.sorted_school_names
      end

      def details?
        school_names.size > SCHOOLS_DETAILS_THRESHOLD
      end

      def summary_text
        t("publish.courses.schools.attached", count: school_names.size)
      end

      def school_list
        content_tag(:ul, class: "govuk-list") do
          safe_join(school_names.map { |name| content_tag(:li, name) })
        end
      end
    end
  end
end
