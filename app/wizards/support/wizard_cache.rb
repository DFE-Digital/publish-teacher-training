# frozen_string_literal: true

module Support
  module WizardCache
    EXPIRY = 24.hours

    # Development leaves Rails.cache as a null store unless caching is switched on.
    # A memory store keeps the wizard answers between requests without using the session.
    def self.store
      return Rails.cache unless Rails.cache.is_a?(ActiveSupport::Cache::NullStore)

      @store ||= ActiveSupport::Cache::MemoryStore.new
    end
  end
end
