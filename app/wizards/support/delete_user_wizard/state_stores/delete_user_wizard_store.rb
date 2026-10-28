# frozen_string_literal: true

class Support::DeleteUserWizard
  module StateStores
    class DeleteUserWizardStore
      include DfE::Wizard::Core::StateStore
    end
  end
end
