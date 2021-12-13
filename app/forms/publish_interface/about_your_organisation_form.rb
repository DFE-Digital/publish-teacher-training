module PublishInterface
  class AboutYourOrganisationForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :provider
    attr_accessor(
      :provider_code, :recruitment_cycle_year, :provider_name,
      :train_with_us, :train_with_disability,
      :email, :telephone, :urn, :website, :ukprn, :address1, :address2,
      :address3, :address4, :postcode, :region_code
    )

    def self.build_from_provider(provider)
      new(
        provider: provider,
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        provider_name: provider.provider_name,
        train_with_us: provider.train_with_us,
        train_with_disability: provider.train_with_disability,

        email: provider.email,
        telephone: provider.telephone,
        urn: provider.urn,
        website: provider.website,
        ukprn: provider.ukprn,
        address1: provider.address1,
        address2: provider.address2,
        address3: provider.address3,
        address4: provider.address4,
        postcode: provider.postcode,
        region_code: provider.region_code,
      )
    end

    def accredited_bodies
      @accredited_bodies ||= @provider.accredited_bodies.map do |ab|
        AccreditedBody.new(
          provider_name: ab[:provider_name],
          provider_code: ab[:provider_code],
          description: ab[:description],
        )
      end
    end

    def valid?
      @provider.valid?
    end

    def save(params)
      accredited_bodies_params = params.delete(:accredited_bodies)
      provider_params = params.except(:page)

      update_provider(provider_params)
      update_accrediting_enrichment(accredited_bodies_params)
      promote_errors
    end

  private

    def update_provider(provider_params)
      @provider.assign_attributes(provider_params)
      @provider.save
    end

    def update_accrediting_enrichment(accredited_bodies_params)
      return if accredited_bodies_params.blank?

      @provider.accrediting_provider_enrichments =
        accredited_bodies_params.map do |accredited_body|
          {
            UcasProviderCode: accredited_body["provider_code"],
            Description: accredited_body["description"],
          }
        end
      @provider.save
    end

    def promote_errors
      @provider.errors.each do |attribute, error|
        errors.add(attribute, error)
      end
    end

    class AccreditedBody
      include ActiveModel::Model

      attr_accessor :provider_name, :provider_code, :description
    end
  end
end
