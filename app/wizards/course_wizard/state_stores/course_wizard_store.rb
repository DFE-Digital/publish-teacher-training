# frozen_string_literal: true

class CourseWizard
  module StateStores
    class CourseWizardStore
      include DfE::Wizard::StateStore

      def further_education_level?
        level == "further_education"
      end

      def primary_level?
        level == "primary"
      end

      def fee_based?
        funding_type == "fee"
      end

      # Employment-based funding types are salary and apprenticeship.
      def salary_based?
        funding_type.in?(%w[salary apprenticeship])
      end

      def undergraduate_degree_with_qts?
        qualification == "undergraduate_degree_with_qts"
      end

      def visa_sponsorship_required?
        ActiveModel::Type::Boolean.new.cast(can_sponsor_student_visa)
      end

      def skilled_worker_visa_sponsorship_required?
        ActiveModel::Type::Boolean.new.cast(can_sponsor_skilled_worker_visa)
      end

      def deadline_for_application_visa_sponsorship_required?
        ActiveModel::Type::Boolean.new.cast(visa_sponsorship_application_deadline_required)
      end

      def design_technology_specialisms?
        secondary_subject_selected?(SecondarySubject.design_technology&.id)
      end

      def physics_specialisms?
        secondary_subject_selected?(SecondarySubject.physics&.id)
      end

      def modern_languages_specialisms?
        secondary_subject_selected?(SecondarySubject.modern_languages&.id)
      end

    private

      def secondary_subject_selected?(subject_id)
        return false if subject_id.blank?

        selected_secondary_subject_ids.include?(subject_id.to_s)
      end

      def selected_secondary_subject_ids
        [secondary_master_subject_id, subordinate_subject_id].compact_blank.map(&:to_s)
      end
    end
  end
end
