# frozen_string_literal: true

class CourseWizard
  module Repositories
    class Course < DfE::Wizard::Repository::Cache
      CACHE_EXPIRY = 24.hours

      def initialize(provider_code:, recruitment_cycle_year:, state_key:, cache: Rails.cache, expires_in: CACHE_EXPIRY)
        super(
          cache:,
          key: self.class.cache_key(provider_code:, recruitment_cycle_year:, state_key:),
          expires_in:,
        )
      end

      def self.cache_key(provider_code:, recruitment_cycle_year:, state_key:)
        "course_wizard_#{provider_code}_#{recruitment_cycle_year}_#{state_key}"
      end
    end
  end
end
