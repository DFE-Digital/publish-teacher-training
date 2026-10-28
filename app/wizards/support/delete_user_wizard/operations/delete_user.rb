# frozen_string_literal: true

class Support::DeleteUserWizard
  module Operations
    class DeleteUser
      # repository is part of the DfE::Wizard operation interface
      # rubocop:disable Lint/UnusedMethodArgument
      def initialize(repository:, step:)
        @wizard = step.wizard
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def execute
        @wizard.user.destroy!
        { success: true }
      end

      def rollback; end
    end
  end
end
