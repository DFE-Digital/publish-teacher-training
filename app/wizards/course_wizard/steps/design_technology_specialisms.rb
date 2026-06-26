# frozen_string_literal: true

class CourseWizard
  module Steps
    class DesignTechnologySpecialisms
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      attribute :design_technology_ids

      validate :specialisms_selected

      def design_technologies
        DesignTechnologySubject.all.sort_by(&:subject_name)
      end

      def self.permitted_params
        [{ design_technology_ids: [] }]
      end

    private

      def specialisms_selected
        return if selected_specialism_ids.any?

        errors.add(:design_technology_ids, I18n.t("course_wizard.steps.design_technology_specialisms.errors.design_technology_ids.blank"))
      end

      def selected_specialism_ids
        Array(design_technology_ids).compact_blank
      end
    end
  end
end
