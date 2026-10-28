# frozen_string_literal: true

class Support::RemoveUserProviderWizard
  module Operations
    class RemoveProvider
      # repository is part of the DfE::Wizard operation interface
      # rubocop:disable Lint/UnusedMethodArgument
      def initialize(repository:, step:)
        @wizard = step.wizard
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def execute
        UserAssociationsService::Delete.call(user: @wizard.user, providers: @wizard.provider)
        { success: true }
      end

      def rollback; end
    end
  end
end
