# frozen_string_literal: true

class CourseWizard
  module Operations
    # Commits an edit of a saved course. dfe-wizard runs it once, when the
    # edit's last question is saved (for a published course, when the user
    # confirms the changes), unless nothing changed or the course changed
    # since the edit started.
    #
    # It maps the changeset diff (the changed answers on the path) to the
    # course, then applies the funding and visa rules whatever the diff
    # holds, and saves the course and its draft enrichment together.
    class UpdateCourse
      ATTRIBUTES = {
        funding_type: :funding,
        can_sponsor_student_visa: :can_sponsor_student_visa,
        can_sponsor_skilled_worker_visa: :can_sponsor_skilled_worker_visa,
      }.freeze

      # repository is part of the DfE::Wizard operation interface
      # rubocop:disable Lint/UnusedMethodArgument
      def initialize(repository:, step:)
        @wizard = step.wizard
      end
      # rubocop:enable Lint/UnusedMethodArgument

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

      def rollback; end

    private

      def course
        @wizard.record
      end

      def diff
        @diff ||= @wizard.changeset.diff
      end

      def assign_deadline
        if diff[:visa_sponsorship_application_deadline_required] == false
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
