module Providers
  class CreateFakeProviderService
    attr_reader :errors

    def initialize(recruitment_cycle:, provider_name:, provider_code:, provider_type:, is_accredited_body:)
      @recruitment_cycle = recruitment_cycle
      @provider_name = provider_name
      @provider_code = provider_code
      @provider_type = provider_type
      @is_accredited_body = is_accredited_body

      @errors = []
    end

    def execute
      if provider_already_exists?
        errors << "Provider #{@provider_name} (#{@provider_code}) already exists."
        return false
      end

      provider = @recruitment_cycle.providers.build(
        provider_name: @provider_name,
        provider_code: @provider_code,
        provider_type: @provider_type,
        accrediting_provider: @is_accredited_body ? "accredited_body" : "not_an_accredited_body",
        address1: "1 Test Street",
        address3: "Town",
        address4: "County",
        postcode: "M1 1JG",
        region_code: "north_west",
      )

      organisation = Organisation.new(name: @provider_name)
      organisation.providers << provider
      if organisation.save
        site_created = provider.sites.create(
          location_name: "Site 1",
          address1: provider.address1,
          address2: provider.address2,
          address3: provider.address3,
          address4: provider.address4,
          postcode: provider.postcode,
          region_code: provider.region_code,
        )
        errors << "Unable to create Site for #{provider_name}." unless site_created
      else
        errors << "Unable to create Organisation for #{provider_name}: #{organisation.errors.to_sentence}."
      end

      if provider.invalid?
        errors << "Unable to create Provider #{provider_name}: #{provider.errors.to_sentence}."
      end

      if errors.any?
        false
      else
        true
      end
    end

  private

    def provider_already_exists?
      @recruitment_cycle.providers.exists?(provider_name: @provider_name) || \
        @recruitment_cycle.providers.exists?(provider_code: @provider_code)
    end
  end
end
