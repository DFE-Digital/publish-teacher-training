# frozen_string_literal: true

module Providers
  class CreateFakeProviderService
    attr_reader :errors

    DEFAULT_PROVIDER_ATTRIBUTES = {
      address1: '1 Test Street',
      town: 'Town',
      address4: 'County',
      postcode: 'M1 1JG',
      region_code: 'north_west',
      ukprn: '12345678'
    }.freeze

    def initialize(recruitment_cycle:, provider_name:, provider_code:, provider_type:, is_accredited_provider:)
      raise 'Can only be run in sandbox or development' unless Rails.env.sandbox? || Rails.env.development? || Rails.env.test?

      @recruitment_cycle = recruitment_cycle
      @provider_name = provider_name
      @provider_code = provider_code
      @provider_type = provider_type
      @is_accredited_provider = is_accredited_provider

      @errors = []
    end

    def execute
      return false if provider_already_exists?
      return false if attempting_to_make_lead_partner_accredited_provider?

      provider = @recruitment_cycle.providers.build({
        provider_name: @provider_name,
        provider_code: @provider_code,
        provider_type: @provider_type,
        accrediting_provider: @is_accredited_provider ? 'accredited_provider' : 'not_an_accredited_provider'
      }.merge(DEFAULT_PROVIDER_ATTRIBUTES))

      organisation = Organisation.new(name: @provider_name)
      organisation.providers << provider
      organisation.save!

      provider.sites.create!(
        location_name: 'Site 1',
        address1: provider.address1,
        address2: provider.address2,
        address3: provider.address3,
        town: provider.town,
        address4: provider.address4,
        postcode: provider.postcode,
        region_code: provider.region_code,
        urn: Faker::Number.number(digits: [5, 6].sample)
      )

      true
    end

    private

    def provider_already_exists?
      if @recruitment_cycle.providers.exists?(provider_code: @provider_code)
        errors << "Provider #{@provider_name} (#{@provider_code}) already exists."
        true
      else
        false
      end
    end

    def attempting_to_make_lead_partner_accredited_provider?
      errors << "Provider #{@provider_name} (#{@provider_code}) cannot be both a lead school and an accredited provider." if @provider_type == 'lead_partner' && @is_accredited_provider
    end
  end
end
