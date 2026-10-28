# frozen_string_literal: true

class Support::DeleteUserWizard
  module Repositories
    class DeleteUser < DfE::Wizard::Repository::Cache
      def initialize(recruitment_cycle_year:, user_id:, expires_in: Support::WizardCache::EXPIRY, cache: Support::WizardCache.store)
        super(
          cache:,
          key: self.class.cache_key(recruitment_cycle_year:, user_id:),
          expires_in:,
        )
      end

      def self.cache_key(recruitment_cycle_year:, user_id:)
        "support_delete_user_wizard_#{recruitment_cycle_year}_#{user_id}"
      end
    end
  end
end
