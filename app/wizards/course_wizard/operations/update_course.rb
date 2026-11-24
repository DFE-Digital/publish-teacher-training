# frozen_string_literal: true

class CourseWizard
  module Operations
    # Saves an edit of a saved course (the edit journey of CourseWizard): its
    # answers mapped to the course, then the funding and visa rules. The
    # course and its draft enrichment are saved together. Nothing is saved
    # when the answers do not change the course.
    class UpdateCourse
      # repository and step are the DfE::Wizard operation interface. The
      # wizard builds one with wizard: to ask whether the edit changes the
      # course.
      # rubocop:disable Lint/UnusedMethodArgument
      def initialize(repository: nil, step: nil, wizard: step.wizard)
        @wizard = wizard
      end
      # rubocop:enable Lint/UnusedMethodArgument

      # The answers would change the course
      def changes?
        fresh_course = ::Course.find(course.id)
        fresh_course.assign_attributes(Mapper.new.to_attributes(answers, fresh_course))
        fresh_course.changed?
      end

      def execute
        course.assign_attributes(Mapper.new.to_attributes(answers, course))
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

      # The answers of the edit's questions on the path
      def answers
        (@wizard.flow_path(@wizard.check_answers_step) & CourseWizard::EDITABLE_STEPS)
          .flat_map { |step_id| @wizard.find_step(step_id).attribute_names.map(&:to_sym) }
          .index_with { |attribute| @wizard.state_store.public_send(attribute) }
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
