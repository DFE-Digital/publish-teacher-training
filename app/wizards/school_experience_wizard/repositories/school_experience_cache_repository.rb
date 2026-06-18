# frozen_string_literal: true

class SchoolExperienceWizard
  module Repositories
    class SchoolExperienceCacheRepository < DfE::Wizard::Repository::Cache
      CACHE_EXPIRY = 24.hours

      def initialize(provider_code:, recruitment_cycle_year:, course_code:, expires_in: CACHE_EXPIRY, cache: Rails.cache)
        super(
          cache:,
          key: self.class.cache_key(provider_code:, recruitment_cycle_year:, course_code:),
          expires_in:,
        )
      end

      def self.cache_key(provider_code:, recruitment_cycle_year:, course_code:)
        "school_experience_wizard_#{provider_code}_#{recruitment_cycle_year}_#{course_code}"
      end
    end
  end
end
