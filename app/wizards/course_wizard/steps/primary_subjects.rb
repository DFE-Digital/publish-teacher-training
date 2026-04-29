# frozen_string_literal: true

class CourseWizard
  module Steps
    class PrimarySubjects
      include DfE::Wizard::Step

      attribute :master_subject_id, :string

      validates :master_subject_id,
                presence: { message: I18n.t("course_wizard.steps.primary_subjects.errors.master_subject_id.blank") }

      def selectable_subjects
        SubjectsCache.new.primary_subjects.map { |subject| [subject.subject_name, subject.id] }
      end

      def self.permitted_params
        [:master_subject_id]
      end
    end
  end
end
