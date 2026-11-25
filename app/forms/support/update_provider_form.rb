# frozen_string_literal: true

module Support
  class UpdateProviderForm
    # Exactly 3 characters, at least one number, letters uppercase.
    PROVIDER_CODE_FORMAT = /\A(?=[A-Z0-9]{3}\z)(?=.*\d)[A-Z0-9]{3}\z/

    delegate :valid?, to: :provider

    def initialize(provider, attributes:)
      @provider = provider
      @attributes = attributes
      assign_attributes
    end

    def save
      code_error = provider_code_error
      provider.valid?
      replace_provider_code_error(code_error)
      return false if provider.errors.any?

      provider.save!
    end

    def provider_code_updated?
      provider.saved_change_to_provider_code?
    end

    def submitted_provider_code
      return unless provider_code_submitted?

      attribute_value(:provider_code).to_s
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

    def provider_code_error
      return unless provider_code_submitted?

      code = submitted_provider_code
      return :wrong_length unless code.length == 3
      return :invalid_format unless PROVIDER_CODE_FORMAT.match?(code)
      return :in_use if provider_code_in_use?(code)

      nil
    end

    def replace_provider_code_error(code_error)
      return if code_error.blank?

      provider.errors.delete(:provider_code)
      provider.errors.add(:provider_code, code_error)
    end

    def provider_code_in_use?(code)
      Provider.where(recruitment_cycle_id: provider.recruitment_cycle_id, provider_code: code)
              .where.not(id: provider.id)
              .exists?
    end

    def provider_code_submitted?
      attributes.key?(:provider_code) || attributes.key?("provider_code")
    end

    def attribute_value(name)
      attributes[name].nil? ? attributes[name.to_s] : attributes[name]
    end
  end
end
