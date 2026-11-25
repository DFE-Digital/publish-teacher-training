# frozen_string_literal: true

module Support
  module Providers
    # Creates a provider and its first user from a submitted onboarding request.
    # Returns true on success. On failure it returns false and the reasons are on
    # onboarding_request.errors, so the support page can render them with the
    # form builder error summary.
    class OnboardFromFormRequest
      include ServicePattern

      PROVIDER_CODE_ATTEMPTS = 5

      def initialize(onboarding_request:)
        @onboarding_request = onboarding_request
      end

      def call
        # with_lock reloads the request, so the onboard checks use the latest row.
        # requires_new gives a savepoint, so ActiveRecord::Rollback undoes the
        # provider even when a caller already has a transaction open.
        onboarded = onboarding_request.with_lock(requires_new: true) do
          next false unless onboarding_request.valid?(:onboard)

          provider = create_provider
          create_first_user(provider)
          onboarding_request.update!(status: :onboarded, provider:)
        end

        onboarded == true
      end

    private

      attr_reader :onboarding_request

      def create_provider
        recruitment_cycle = RecruitmentCycle.current_recruitment_cycle
        fail_with!(onboarding_error("no_recruitment_cycle")) if recruitment_cycle.nil?

        PROVIDER_CODE_ATTEMPTS.times do
          code = ProviderCode.call(recruitment_cycle:)
          break if code.blank?

          provider = recruitment_cycle.providers.new(provider_attributes(code))
          return provider if save_provider(provider)
        end

        fail_with!(onboarding_error("code_generation_failed"))
      end

      # Returns false when the provider code is taken, so the caller can try another code.
      def save_provider(provider)
        if provider.valid?
          ActiveRecord::Base.transaction(requires_new: true) { provider.save! }
          return true
        end

        provider_invalid(provider)
      rescue ActiveRecord::RecordNotUnique
        false
      rescue ActiveRecord::RecordInvalid
        provider_invalid(provider)
      end

      def provider_invalid(provider)
        return false if provider.errors.of_kind?(:provider_code, :taken)

        fail_with!(*record_errors(provider, "provider_invalid"))
      end

      def provider_attributes(code)
        {
          provider_name: onboarding_request.provider_name,
          provider_code: code,
          provider_type: onboarding_request.provider_type,
          ukprn: onboarding_request.ukprn,
          urn: (onboarding_request.urn if onboarding_request.lead_school?),
          accredited: onboarding_request.accredited_provider,
          accredited_provider_number:,
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

      def create_first_user(provider)
        user = User.find_or_initialize_by(email: normalized_email)

        if user.new_record?
          user.first_name = onboarding_request.first_name
          user.last_name = onboarding_request.last_name
          fail_with!(*record_errors(user, "user_invalid")) unless user.save
        end

        UserAssociationsService::Create.call(user:, provider:, limit_to_provider: true)
      end

      def accredited_provider_number
        return unless onboarding_request.accredited_provider?

        onboarding_request.accredited_provider_number
      end

      def normalized_email
        onboarding_request.email_address.to_s.strip.downcase
      end

      # The request passed its own validations, so a provider or user failure here
      # means the two sets of rules differ. These errors go on base.
      def record_errors(record, prefix_key)
        prefix = onboarding_error(prefix_key)
        record.errors.map { |error| "#{prefix} #{error.message.delete_prefix('^')}" }
      end

      # Adds the messages to the request and undoes everything done in the lock.
      def fail_with!(*messages)
        messages.each { |message| onboarding_request.errors.add(:base, message) }
        raise ActiveRecord::Rollback
      end

      def onboarding_error(key)
        I18n.t("support.providers.onboard_from_form_request.#{key}")
      end
    end
  end
end
