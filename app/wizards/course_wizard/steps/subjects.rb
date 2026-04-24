# frozen_string_literal: true

class CourseWizard
  module Steps
    class Subjects
      include DfE::Wizard::Step

      attribute :master_subject_id, :string
      attribute :subordinate_subject_id, :string

      validates :master_subject_id,
                presence: { message: I18n.t("activerecord.errors.models.course.attributes.subjects.course_creation").delete_prefix("^") }

      def primary_level?
        wizard.state_store.level == "primary"
      end

      def secondary_level?
        wizard.state_store.level == "secondary"
      end

      def selectable_subjects
        source_subjects = if primary_level?
                            SubjectsCache.new.primary_subjects
                          else
                            SubjectsCache.new.secondary_subjects
                          end

        source_subjects.map { |subject| [subject.subject_name, subject.id] }
      end

      def self.permitted_params
        %i[master_subject_id subordinate_subject_id]
      end
    end
  end
end
