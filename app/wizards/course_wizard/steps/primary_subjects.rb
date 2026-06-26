# frozen_string_literal: true

class CourseWizard
  module Steps
    class PrimarySubjects
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      attribute :primary_master_subject_id, :string

      validates :primary_master_subject_id,
                presence: { message: I18n.t("course_wizard.steps.primary_subjects.errors.primary_master_subject_id.blank") }

      review do |r|
        r.row(
          label: :subjects,
          label_options: ->(draft) { { count: draft.subjects.count } },
          value: ->(draft) { draft.subjects.map(&:subject_name) },
          formatter: :subjects,
        )
      end

      def selectable_subjects
        SubjectsCache.new.primary_subjects.map { |subject| [subject.subject_name, subject.id] }
      end

      def self.permitted_params
        [:primary_master_subject_id]
      end
    end
  end
end
