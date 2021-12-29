module PublishInterface
  class AboutYourOrganisationForm
    include ActiveModel::Model
    include ActiveModel::Validations

    FIELDS = %i[
      train_with_us
      train_with_disability
    ].freeze

    attr_accessor :provider
    delegate :recruitment_cycle_year, :provider_code, :provider_name, to: :provider
    attr_accessor :_accredited_bodies_data
    attr_accessor(*FIELDS)

    def self.build_from_provider(provider)
      fields_to_populate = provider.attributes.symbolize_keys.slice(*FIELDS)

      form = new(fields_to_populate)
      form.provider = provider
      form._accredited_bodies_data = provider.accredited_bodies
      form
    end

    def self.build_from_controller_params(params)
      accredited_bodies_params = params.delete(:accredited_bodies)
      provider = params.delete(:provider)

      form = new(params)
      form.provider = provider
      form._accredited_bodies_data = accredited_bodies_params
      form.provider.assign_attributes(params)
      form
    end

    def accredited_bodies
      _accredited_bodies_data.map do |ab|
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

    def save
      Provider.transaction do
        update_provider
        update_accrediting_enrichment
      end
      promote_errors
    end

  private

    def update_provider
      @provider.save
    end

    def update_accrediting_enrichment
      return if _accredited_bodies_data.blank?

      @provider.accrediting_provider_enrichments =
        accredited_bodies.map do |accredited_body|
          {
            UcasProviderCode: accredited_body.provider_code,
            Description: accredited_body.description,
          }
        end
      @provider.save
    end

    def promote_errors
      @provider.errors.each do |error|
        errors.add(error.attribute, error.full_message)
      end
    end

    class AccreditedBody
      include ActiveModel::Model

      attr_accessor :provider_name, :provider_code, :description
    end
  end
end
