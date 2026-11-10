# frozen_string_literal: true

class Support::AddProviderWizard
  module Steps
    class ProviderDetails
      include DfE::Wizard::Step

      UNIVERSITY_ACCREDITED_PROVIDER_NUMBER_FORMAT = /\A1\d{3}\z/
      SCITT_ACCREDITED_PROVIDER_NUMBER_FORMAT = /\A5\d{3}\z/
      ACCREDITED_PROVIDER_NUMBER_FORMAT = /\A[15]\d{3}\z/
      # Exactly three letters or digits, with at least one digit.
      PROVIDER_CODE_FORMAT = /\A(?=[a-zA-Z0-9]{3}$)(?=.*\d)[a-zA-Z\d]{3}\z/

      attribute :provider_name, :string
      attribute :provider_code, :string
      attribute :ukprn, :string
      attribute :accredited, :string
      attribute :accredited_provider_number, :string
      attribute :provider_type, :string
      attribute :urn, :string

      validates :provider_name, presence: true, length: { maximum: 100 }
      validates :provider_code, presence: true, length: { is: 3 }, format: { with: PROVIDER_CODE_FORMAT }
      validate :provider_code_taken
      validate :validate_accredited_provider_number
      validates :ukprn, ukprn_format: { allow_blank: false }
      validates :provider_type, presence: true
      validate :provider_type_school_is_an_invalid_accredited_provider
      validates :urn, presence: true, reference_number_format: { allow_blank: true, minimum: 5, maximum: 6, message: :invalid }, if: -> { !accredited? && lead_school? }

      def self.permitted_params
        %i[provider_name provider_code ukprn accredited accredited_provider_number provider_type urn]
      end

      def accredited?
        ActiveModel::Type::Boolean.new.cast(accredited)
      end

      def lead_school?
        provider_type&.to_sym == :lead_school
      end

    private

      def scitt?
        provider_type&.to_sym == :scitt
      end

      def university?
        provider_type&.to_sym == :university
      end

      def provider_code_taken
        return if provider_code.blank?

        errors.add(:provider_code, :taken) if Provider.exists?(recruitment_cycle: wizard.recruitment_cycle, provider_code: provider_code.upcase)
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
end
