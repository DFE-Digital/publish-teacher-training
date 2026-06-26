# frozen_string_literal: true

class CourseWizard
  module Steps
    class SecondarySubjects
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      attribute :secondary_master_subject_id, :string
      attribute :subordinate_subject_id, :string

      validates :secondary_master_subject_id,
                presence: { message: I18n.t("course_wizard.steps.secondary_subjects.errors.secondary_master_subject_id.blank") }

      validate :validate_secondary_master_subject_id_is_not_same_as_subordinate_subject_id

      review do |r|
        r.row(
          label: :subjects,
          label_options: ->(draft) { { count: draft.subjects.count } },
          value: ->(draft) { draft.subjects.map(&:subject_name) },
          formatter: :subjects,
        )
      end

      def selectable_subjects
        SecondarySubject.order(:subject_name).map { |subject| [subject.subject_name, subject.id] }
      end

      def self.permitted_params
        %i[secondary_master_subject_id subordinate_subject_id]
      end

      def validate_secondary_master_subject_id_is_not_same_as_subordinate_subject_id
        if secondary_master_subject_id == subordinate_subject_id
          errors.add(:secondary_master_subject_id, I18n.t("course_wizard.steps.secondary_subjects.errors.secondary_master_subject_id.same_as_subordinate_subject_id"))
        end
      end
    end
  end
end
