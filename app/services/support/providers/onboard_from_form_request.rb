# frozen_string_literal: true

module Support
  module Providers
    class OnboardFromFormRequest
      include ServicePattern

      class Error < StandardError; end

      Result = Data.define(:provider, :error_message) do
        def success?
          error_message.blank?
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

        Result.new(provider:, error_message: nil)
      rescue Error => e
        Result.new(provider: nil, error_message: e.message)
      end

    private

      attr_reader :onboarding_request

      def ensure_can_onboard!
        if onboarding_request.onboarded? || onboarding_request.provider_id.present?
          raise Error, t("already_onboarded")
        end

        raise Error, t("not_submitted") unless onboarding_request.submitted?
      end

      def create_provider!
        recruitment_cycle = RecruitmentCycle.current_recruitment_cycle
        raise Error, t("no_recruitment_cycle") if recruitment_cycle.nil?

        5.times do
          code = ProviderCode.call(recruitment_cycle:)
          raise Error, t("code_generation_failed") if code.blank?

          provider = recruitment_cycle.providers.new(provider_attributes(code))
          return provider if save_provider(provider)
        end

        raise Error, t("code_generation_failed")
      end

      def save_provider(provider)
        unless provider.valid?
          raise Error, provider_error_message(provider) unless provider.errors.of_kind?(:provider_code, :taken)

          return false
        end

        ActiveRecord::Base.transaction(requires_new: true) do
          provider.save!
        end

        true
      rescue ActiveRecord::RecordNotUnique
        false
      rescue ActiveRecord::RecordInvalid => e
        raise Error, provider_error_message(e.record) unless e.record.errors.of_kind?(:provider_code, :taken)

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
          raise Error, user_error_message(user) unless user.save
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

      def provider_error_message(provider)
        "#{t('provider_invalid')} #{provider.errors.full_messages.join('. ')}"
      end

      def user_error_message(user)
        "#{t('user_invalid')} #{user.errors.full_messages.join('. ')}"
      end

      def t(key)
        I18n.t("support.providers.onboard_from_form_request.#{key}")
      end
    end
  end
end
