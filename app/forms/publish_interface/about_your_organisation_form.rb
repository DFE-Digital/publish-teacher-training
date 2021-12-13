module PublishInterface
  class AboutYourOrganisationForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :provider
    attr_accessor(
      :provider_code, :recruitment_cycle_year, :provider_name,
      :train_with_us, :train_with_disability
    )

    def self.build_from_provider(provider)
      new(
        provider: provider,
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        provider_name: provider.provider_name,
        train_with_us: provider.train_with_us,
        train_with_disability: provider.train_with_disability,
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

      # update_provider
      @provider.assign_attributes(provider_params)
      @provider.save

      # update_accrediting_enrichment
      @provider.accrediting_provider_enrichments =
        accredited_bodies_params.map do |accredited_body|
          {
            UcasProviderCode: accredited_body["provider_code"],
            Description: accredited_body["description"],
          }
        end
      @provider.save

      promote_errors
    end

  private

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
