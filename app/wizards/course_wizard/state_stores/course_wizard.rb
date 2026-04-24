# frozen_string_literal: true

class CourseWizard
  module StateStores
    class CourseWizard
      include DfE::Wizard::StateStore

      def further_education_level?
        level == "further_education"
      end
    end
  end
end
