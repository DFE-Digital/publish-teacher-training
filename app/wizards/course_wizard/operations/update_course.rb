# frozen_string_literal: true

class CourseWizard
  module Operations
    # Saves an edit of a saved course (see EditCourseWizard): its answers
    # mapped to the course, then the funding and visa rules. The course and
    # its draft enrichment are saved together. Nothing is saved when the
    # answers do not change the course.
    class UpdateCourse
      # repository is part of the DfE::Wizard operation interface
      # rubocop:disable Lint/UnusedMethodArgument
      def initialize(repository:, step:)
        @wizard = step.wizard
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def execute
        course.assign_attributes(Mapper.new.to_attributes(@wizard.answers, course))
        return { success: true, changed: false } unless course.changed?

        funding_changed = course.funding_changed?
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

      def save(enrichment)
        saved = false
        ::Course.transaction do
          saved = (enrichment.nil? || enrichment.save) && course.save
          raise ActiveRecord::Rollback unless saved
        end
        return { success: true, changed: true } if saved

        { success: false, errors: [*enrichment&.errors&.full_messages, *course.errors.full_messages].uniq }
      end
    end
  end
end
