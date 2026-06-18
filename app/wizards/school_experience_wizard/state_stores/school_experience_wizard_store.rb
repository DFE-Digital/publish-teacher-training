# frozen_string_literal: true

class SchoolExperienceWizard
  module StateStores
    class SchoolExperienceWizardStore
      include DfE::Wizard::StateStore

      def experience_is_required?
        ActiveModel::Type::Boolean.new.cast(experience_required)
      end
    end
  end
end
