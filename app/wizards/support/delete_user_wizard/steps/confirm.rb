# frozen_string_literal: true

class Support::DeleteUserWizard
  module Steps
    class Confirm
      include DfE::Wizard::Step

      def self.permitted_params
        []
      end
    end
  end
end
