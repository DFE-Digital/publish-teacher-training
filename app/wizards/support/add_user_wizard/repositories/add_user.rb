# frozen_string_literal: true

class Support::AddUserWizard
  module Repositories
    class AddUser < DfE::Wizard::Repository::Cache
      def initialize(recruitment_cycle_year:, state_key:, expires_in: Support::WizardCache::EXPIRY, cache: Support::WizardCache.store)
        super(
          cache:,
          key: self.class.cache_key(recruitment_cycle_year:, state_key:),
          expires_in:,
        )
      end

      def self.cache_key(recruitment_cycle_year:, state_key:)
        "support_add_user_wizard_#{recruitment_cycle_year}_#{state_key}"
      end
    end
  end
end
