# frozen_string_literal: true

module Support
  class UpdateProviderForm
    attr_reader :provider

    def initialize(provider, attributes:)
      @provider = provider
      @attributes = attributes
    end

    def save
      @provider.assign_attributes(@attributes)
      remove_accredited_provider_number
      @provider.save
    end

    def remove_accredited_provider_number
      return unless @provider.accrediting_provider_change&.[](1) == 'not_an_accredited_provider'

      @provider.accredited_provider_number = nil
    end
  end
end
