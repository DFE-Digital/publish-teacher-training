module Courses
  module EditCourseOptions
    extend ActiveSupport::Concern
    included do
      def entry_requirements
        Course::ENTRY_REQUIREMENT_OPTIONS
          .reject { |k, _v| %i[not_set not_required].include?(k) }
          .keys
      end

      def qualification_options(course)
        qualifications_with_qts, qualifications_without_qts = Course::qualifications.keys.partition { |q| q.include?('qts') }
        course.level == :further_education ? qualifications_without_qts : qualifications_with_qts
      end

      def age_range_options(course)
        case course.level
        when :primary
          %w[
            3_to_7
            5_to_11
            7_to_11
            7_to_14
          ]
        when :secondary
          %w[
            11_to_16
            11_to_18
            14_to_19
          ]
        end
      end

      def edit_course_options(course)
        {
          entry_requirements: entry_requirements,
          qualifications: qualification_options(course),
          age_range_in_years: age_range_options(course),
          start_dates: start_date_options(course)
        }
      end

      def start_date_options(course)
        recruitment_year = course.provider.recruitment_cycle.year.to_i

        ["August #{recruitment_year}",
         "September #{recruitment_year}",
         "October #{recruitment_year}",
         "November #{recruitment_year}",
         "December #{recruitment_year}",
         "January #{recruitment_year + 1}",
         "February #{recruitment_year + 1}",
         "March #{recruitment_year + 1}",
         "April #{recruitment_year + 1}",
         "May #{recruitment_year + 1}",
         "June #{recruitment_year + 1}",
         "July #{recruitment_year + 1}"]
      end
    end
  end
end
