# frozen_string_literal: true

class CourseWizard
  module Operations
    # Saves an edit of a saved course: the changed answers (the edit's diff)
    # mapped to the course, then the funding and visa rules whatever the diff
    # holds. The course and its draft enrichment are saved together.
    class UpdateCourse
      ATTRIBUTES = {
        funding_type: :funding,
        can_sponsor_student_visa: :can_sponsor_student_visa,
        can_sponsor_skilled_worker_visa: :can_sponsor_skilled_worker_visa,
      }.freeze

      def initialize(course:, diff:)
        @course = course
        @diff = diff
      end

      def execute
        funding_changed = diff.key?(:funding_type) && diff[:funding_type] != course.funding
        course.assign_attributes(diff.slice(*ATTRIBUTES.keys).transform_keys(ATTRIBUTES))
        assign_deadline

        rules = ::Courses::FundingAndVisaRules.new(course)
        rules.reset_opposite_visa
        rules.clear_deadline_unless_sponsoring
        enrichment = rules.reset_enrichment if funding_changed

        save(enrichment)
      end

    private

      attr_reader :course, :diff

      def assign_deadline
        if diff.key?(:visa_sponsorship_application_deadline_required) &&
            !ActiveModel::Type::Boolean.new.cast(diff[:visa_sponsorship_application_deadline_required])
          course.visa_sponsorship_application_deadline_at = nil
        elsif diff.key?(:visa_sponsorship_application_deadline_at)
          course.visa_sponsorship_application_deadline_at = deadline_from(diff[:visa_sponsorship_application_deadline_at])
        end
      end

      def deadline_from(value)
        Draft::DateParts.parse(value)&.to_date&.in_time_zone&.end_of_day
      end

      def save(enrichment)
        saved = false
        ::Course.transaction do
          saved = (enrichment.nil? || enrichment.save) && course.save
          raise ActiveRecord::Rollback unless saved
        end
        return { success: true } if saved

        { success: false, errors: [*enrichment&.errors&.full_messages, *course.errors.full_messages].uniq }
      end
    end
  end
end
