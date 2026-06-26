# frozen_string_literal: true

class CourseWizard
  module Steps
    class ModernLanguagesSpecialisms
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      attribute :language_ids

      validate :languages_selected

      def modern_languages
        ModernLanguagesSubject.all.sort_by(&:subject_name)
      end

      def self.permitted_params
        [{ language_ids: [] }]
      end

    private

      def languages_selected
        return if selected_language_ids.any?

        errors.add(:language_ids, I18n.t("course_wizard.steps.modern_languages_specialisms.errors.language_ids.blank"))
      end

      def selected_language_ids
        Array(language_ids).compact_blank
      end
    end
  end
end
