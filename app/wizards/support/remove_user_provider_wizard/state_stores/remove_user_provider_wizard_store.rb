# frozen_string_literal: true

class Support::RemoveUserProviderWizard
  module StateStores
    class RemoveUserProviderWizardStore
      include DfE::Wizard::Core::StateStore
    end
  end
end
