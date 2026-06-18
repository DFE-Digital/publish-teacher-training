# frozen_string_literal: true

class SchoolExperienceWizard
  module StateStores
    class SchoolExperienceWizardStore
      include DfE::Wizard::StateStore

      def experience_is_required?
        string_to_boolean(experience_required)
      end

      def string_to_boolean(value)
        case value
        when "yes" then true
        when "no" then false
        end
      end
    end
  end
end
