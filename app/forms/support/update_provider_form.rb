# frozen_string_literal: true

module Support
  class UpdateProviderForm
    delegate :valid?, to: :provider

    def initialize(provider, attributes:)
      @provider = provider
      @attributes = attributes
      assign_attributes
    end

    def save
      return false unless provider.valid?

      provider.save!
    end

  private

    attr_reader :provider, :attributes

    def assign_attributes
      @provider.assign_attributes(attributes)
      remove_accredited_provider_number
    end

    def remove_accredited_provider_number
      return unless @provider.accredited_changed?(to: false)

      @provider.accredited_provider_number = nil
    end
  end
end
