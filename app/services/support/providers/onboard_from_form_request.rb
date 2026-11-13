# frozen_string_literal: true

module Support
  module Providers
    class OnboardFromFormRequest
      include ServicePattern

      PROVIDER_ATTRIBUTES = {
        "provider_name" => :provider_name,
        "provider_type" => :provider_type,
        "accredited" => :provider_type,
        "ukprn" => :ukprn,
        "urn" => :urn,
        "accredited_provider_number" => :accredited_provider_number,
        "email" => :contact_email_address,
        "telephone" => :telephone,
        "website" => :website,
        "address1" => :address_line_1,
        "address2" => :address_line_1,
        "address3" => :address_line_1,
        "town" => :address_line_1,
        "address4" => :address_line_1,
        "postcode" => :address_line_1,
      }.freeze

      USER_ATTRIBUTES = {
        "email" => :email_address,
        "first_name" => :first_name,
        "last_name" => :last_name,
      }.freeze

      class Error < StandardError
        attr_reader :errors

        def initialize(errors)
          items = errors.is_a?(Array) ? errors : [errors]
          @errors = items.map { |error| error.is_a?(Hash) ? error : { message: error.to_s } }
          super(@errors.pluck(:message).join(" "))
        end
      end

      Result = Data.define(:provider, :errors) do
        def success?
          errors.blank?
        end

        def error_message
          errors.pluck(:message).join(" ")
        end
      end

      def initialize(onboarding_request:)
        @onboarding_request = onboarding_request
      end

      def call
        provider = nil

        onboarding_request.with_lock do
          ensure_can_onboard!
          provider = create_provider!
          create_first_user!(provider)
          onboarding_request.update!(status: :onboarded, provider:)
        end

        Result.new(provider:, errors: [])
      rescue Error => e
        Result.new(provider: nil, errors: e.errors)
      end

    private

      attr_reader :onboarding_request

      def ensure_can_onboard!
        if onboarding_request.onboarded? || onboarding_request.provider_id.present?
          raise Error, { attribute: :base, message: onboarding_error("already_onboarded") }
        end

        raise Error, { attribute: :base, message: onboarding_error("not_submitted") } unless onboarding_request.submitted?
      end

      def create_provider!
        recruitment_cycle = RecruitmentCycle.current_recruitment_cycle
        raise Error, { attribute: :base, message: onboarding_error("no_recruitment_cycle") } if recruitment_cycle.nil?

        5.times do
          code = ProviderCode.call(recruitment_cycle:)
          raise Error, { attribute: :base, message: onboarding_error("code_generation_failed") } if code.blank?

          provider = recruitment_cycle.providers.new(provider_attributes(code))
          return provider if save_provider(provider)
        end

        raise Error, { attribute: :base, message: onboarding_error("code_generation_failed") }
      end

      def save_provider(provider)
        unless provider.valid?
          raise Error, field_errors(provider, PROVIDER_ATTRIBUTES) unless provider.errors.of_kind?(:provider_code, :taken)

          return false
        end

        ActiveRecord::Base.transaction(requires_new: true) do
          provider.save!
        end

        true
      rescue ActiveRecord::RecordNotUnique
        false
      rescue ActiveRecord::RecordInvalid => e
        raise Error, field_errors(e.record, PROVIDER_ATTRIBUTES) unless e.record.errors.of_kind?(:provider_code, :taken)

        false
      end

      def provider_attributes(code)
        {
          provider_name: onboarding_request.provider_name,
          provider_code: code,
          provider_type: onboarding_request.provider_type,
          ukprn: onboarding_request.ukprn,
          urn: onboarding_request.urn,
          accredited: onboarding_request.accredited_provider,
          accredited_provider_number: accredited_provider_number,
          email: onboarding_request.contact_email_address,
          telephone: onboarding_request.telephone,
          website: onboarding_request.website,
          address1: onboarding_request.address_line_1,
          address2: onboarding_request.address_line_2,
          address3: onboarding_request.address_line_3,
          town: onboarding_request.town_or_city,
          address4: onboarding_request.county,
          postcode: onboarding_request.postcode,
          organisations_attributes: [{ name: onboarding_request.provider_name }],
        }
      end

      def create_first_user!(provider)
        user = User.find_or_initialize_by(email: normalized_email)

        if user.new_record?
          user.first_name = onboarding_request.first_name
          user.last_name = onboarding_request.last_name
          raise Error, field_errors(user, USER_ATTRIBUTES) unless user.save
        end

        UserAssociationsService::Create.call(user:, provider:)
      end

      def accredited_provider_number
        return unless onboarding_request.accredited_provider?

        onboarding_request.accredited_provider_number
      end

      def normalized_email
        onboarding_request.email_address.to_s.strip.downcase
      end

      def field_errors(record, attributes)
        record.errors.attribute_names.flat_map do |attribute|
          record.errors.messages_for(attribute).map do |message|
            {
              attribute: attributes[attribute.to_s] || :base,
              message: message.delete_prefix("^"),
            }
          end
        end
      end

      def onboarding_error(key)
        I18n.t("support.providers.onboard_from_form_request.#{key}")
      end
    end
  end
end
