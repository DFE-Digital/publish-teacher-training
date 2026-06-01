module DataHub
  module RemoveProviderSchools
    class SummaryBuilder
      def initialize(removed:, skipped_with_courses:, kept_present:, kept_missing:)
        @removed = removed
        @skipped_with_courses = skipped_with_courses
        @kept_present = kept_present
        @kept_missing = kept_missing
      end

      def short_summary
        {
          removed_count: @removed.size,
          skipped_with_courses_count: @skipped_with_courses.size,
          kept_present_count: @kept_present.size,
          kept_missing_count: @kept_missing.size,
        }
      end

      def full_summary
        {
          removed: @removed,
          skipped_with_courses: @skipped_with_courses,
          kept_present: @kept_present,
          kept_missing: @kept_missing,
        }
      end
    end
  end
end
