# frozen_string_literal: true

module Support
  class ProviderForm < BaseForm
    FIELDS = %i[
      accredited
      accredited_provider_number

      provider_code
      provider_name
      provider_type

      ukprn
      urn
    ].freeze

    UNIVERSITY_ACCREDITED_PROVIDER_NUMBER_FORMAT = /\A1\d{3}\z/
    SCITT_ACCREDITED_PROVIDER_NUMBER_FORMAT = /\A5\d{3}\z/
    ACCREDITED_PROVIDER_NUMBER_FORMAT = /\A[15]\d{3}\z/

    attr_accessor(*FIELDS, :recruitment_cycle)

    def initialize(identifier_model, recruitment_cycle:, params: {})
      @recruitment_cycle = recruitment_cycle
      super(identifier_model, params:)
    end

    validates :provider_name, presence: true, length: { maximum: 100 }

    validates :provider_code, presence: true, length: { is: 3, message: :invalid }

    validate :provider_code_taken

    validate :validate_accredited_provider_number

    validates :ukprn, ukprn_format: { allow_blank: false }

    validates :provider_type, presence: true
    validate :provider_type_school_is_an_invalid_accredited_provider
    validate :provider_cannot_be_demoted_with_open_courses

    validates :urn, presence: true, reference_number_format: { allow_blank: true, minimum: 5, maximum: 6, message: :invalid }, if: -> { !accredited? && lead_school? }

    alias compute_fields new_attributes

    def attributes_to_save
      new_attributes.merge(organisations_attributes: [{ name: provider_name }])
                    .merge(recruitment_cycle:)
    end

    def accredited?
      ActiveModel::Type::Boolean.new.cast(accredited)
    end

    def lead_school?
      provider_type&.to_sym == :lead_school
    end

    private

    delegate :providers, to: :recruitment_cycle

    def scitt?
      provider_type&.to_sym == :scitt
    end

    def university?
      provider_type&.to_sym == :university
    end

    def provider_code_taken
      errors.add(:provider_code, :taken) if providers.exists?(provider_code:)
    end

    def provider_cannot_be_demoted_with_open_courses
      errors.add(:provider_type, :provider_cannot_be_demoted_with_open_courses) if !accredited? && provider.accredited? && provider.courses.published.exists?
    end

    def provider_type_school_is_an_invalid_accredited_provider
      errors.add(:provider_type, :school_is_an_invalid_accredited_provider) if accredited? && lead_school?
    end

    def validate_accredited_provider_number
      return unless accredited?

      if accredited_provider_number.blank?
        errors.add(:accredited_provider_number, :blank)
      else
        regex = if university?
                  UNIVERSITY_ACCREDITED_PROVIDER_NUMBER_FORMAT
                elsif scitt?
                  SCITT_ACCREDITED_PROVIDER_NUMBER_FORMAT
                else
                  ACCREDITED_PROVIDER_NUMBER_FORMAT
                end

        errors.add(:accredited_provider_number, :invalid) unless regex.match?(accredited_provider_number)
      end
    end
  end
end
