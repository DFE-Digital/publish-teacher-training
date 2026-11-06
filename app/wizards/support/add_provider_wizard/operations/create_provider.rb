# frozen_string_literal: true

class Support::AddProviderWizard
  module Operations
    class CreateProvider
      # repository is part of the DfE::Wizard operation interface
      # rubocop:disable Lint/UnusedMethodArgument
      def initialize(repository:, step:)
        @step = step
        @wizard = step.wizard
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def execute
        provider = @wizard.recruitment_cycle.providers.new(provider_attributes)

        if provider.save
          @wizard.created_provider = provider
          { success: true }
        else
          provider.errors.full_messages.each { |message| @step.errors.add(:base, message) }
          { success: false, errors: @step.errors }
        end
      end

    private

      def provider_attributes
        provider_details = @wizard.step(:provider_details).serializable_data
        contact_details = @wizard.step(:contact_details).serializable_data

        provider_details
          .merge(contact_details)
          .merge("organisations_attributes" => [{ name: provider_details["provider_name"] }])
      end
    end
  end
end
