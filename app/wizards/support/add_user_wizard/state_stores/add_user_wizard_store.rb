# frozen_string_literal: true

class Support::AddUserWizard
  module StateStores
    class AddUserWizardStore
      include DfE::Wizard::Core::StateStore
    end
  end
end
