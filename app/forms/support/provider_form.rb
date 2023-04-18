# frozen_string_literal: true

module Support
  class ProviderForm < BaseForm
    FIELDS = %i[
      accredited_provider
      accredited_provider_id

      provider_code
      provider_name
      provider_type

      ukprn
      urn
    ].freeze

    UNIVERSITY_ACCREDITED_PROVIDER_ID_FORMAT = /\A1\d{3}\z/
    SCITT_ACCREDITED_PROVIDER_ID_FORMAT = /\A5\d{3}\z/
    ACCREDITED_PROVIDER_ID_FORMAT = /\A[15]\d{3}\z/

    attr_accessor(*FIELDS, :recruitment_cycle)

    def initialize(identifier_model, recruitment_cycle:, params: {})
      @recruitment_cycle = recruitment_cycle
      super(identifier_model, params:)
    end

    validates :provider_name, presence: true, length: { maximum: 100 }

    validates :provider_code, presence: true, length: { is: 3, message: :invalid }

    validate :provider_code_taken

    validates :accredited_provider, presence: true
    validate :validate_accredited_provider_id

    validates :ukprn, ukprn_format: true
    
    validates :provider_type, presence: true
    validate :provider_type_school_is_an_invalid_accredited_provider

    validates :urn, presence: true, reference_number_format: { allow_blank: true, minimum: 5, maximum: 6, message: :invalid }, if: -> { !accredited_body? && lead_school? }

    alias compute_fields new_attributes

    private

    delegate :providers, to: :recruitment_cycle

    def accredited_body?
      accredited_provider&.to_sym == :accredited_body
    end

    def lead_school?
      provider_type&.to_sym == :lead_school
    end

    def scitt?
      provider_type&.to_sym == :scitt
    end

    def university?
      provider_type&.to_sym == :university
    end

    def provider_code_taken
      errors.add(:provider_code, :taken) if providers.exists?(provider_code:)
    end

    def provider_type_school_is_an_invalid_accredited_provider
      errors.add(:provider_type, :school_is_an_invalid_accredited_provider) if accredited_body? && lead_school?
    end

    def validate_accredited_provider_id
      return unless accredited_body?

      if accredited_provider_id.blank?
        errors.add(:accredited_provider_id, :blank)
      else
        regex = if university?
                  UNIVERSITY_ACCREDITED_PROVIDER_ID_FORMAT
                elsif scitt?
                  SCITT_ACCREDITED_PROVIDER_ID_FORMAT
                else
                  ACCREDITED_PROVIDER_ID_FORMAT
                end

        errors.add(:accredited_provider_id, :invalid) unless regex.match?(accredited_provider_id)
      end
    end
  end
end
