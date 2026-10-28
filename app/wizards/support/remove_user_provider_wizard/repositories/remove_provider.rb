# frozen_string_literal: true

class Support::RemoveUserProviderWizard
  module Repositories
    class RemoveProvider < DfE::Wizard::Repository::Cache
      def initialize(recruitment_cycle_year:, user_id:, provider_id:, expires_in: Support::WizardCache::EXPIRY, cache: Support::WizardCache.store)
        super(
          cache:,
          key: self.class.cache_key(recruitment_cycle_year:, user_id:, provider_id:),
          expires_in:,
        )
      end

      def self.cache_key(recruitment_cycle_year:, user_id:, provider_id:)
        "support_remove_user_provider_wizard_#{recruitment_cycle_year}_#{user_id}_#{provider_id}"
      end
    end
  end
end
