# frozen_string_literal: true

class Support::AddUserWizard
  module Steps
    class CheckAnswers
      include DfE::Wizard::Step

      def self.permitted_params
        []
      end
    end
  end
end
