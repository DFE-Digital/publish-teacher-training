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

      def undergraduate_degree_with_qts?
        qualification == "undergraduate_degree_with_qts"
      end

      def visa_sponsorship_required?
        ActiveModel::Type::Boolean.new.cast(can_sponsor_student_visa) == true
      end
    end
  end
end
