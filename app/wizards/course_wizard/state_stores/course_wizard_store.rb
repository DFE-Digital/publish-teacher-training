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
    end
  end
end
