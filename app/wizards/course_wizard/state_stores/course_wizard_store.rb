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
    end
  end
end
