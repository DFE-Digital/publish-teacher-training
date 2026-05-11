# frozen_string_literal: true

class CourseWizard
  module Steps
    class SecondarySubjects
      include DfE::Wizard::Step

      attribute :master_subject_id, :string
      attribute :subordinate_subject_id, :string

      validates :master_subject_id,
                presence: { message: I18n.t("course_wizard.steps.secondary_subjects.errors.master_subject_id.blank") }

      validate :validate_master_subject_id_is_not_same_as_subordinate_subject_id?

      def selectable_subjects
        SubjectsCache.new.secondary_subjects.map { |subject| [subject.subject_name, subject.id] }
      end

      def self.permitted_params
        %i[master_subject_id subordinate_subject_id]
      end

      def validate_master_subject_id_is_not_same_as_subordinate_subject_id?
        if master_subject_id == subordinate_subject_id
          errors.add(:master_subject_id, I18n.t("course_wizard.steps.secondary_subjects.errors.master_subject_id.same_as_subordinate_subject_id"))
        end
      end
    end
  end
end
