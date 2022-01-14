module PublishInterface
  class AboutYourOrganisationForm < BaseProviderForm
  class AboutYourOrganisationForm
    include ActiveModel::Model
    include ActiveModel::Validations

    FIELDS = %i[
      train_with_us
      train_with_disability
      accrediting_provider_enrichments
    ].freeze

    attr_accessor(*FIELDS)

    def accredited_bodies
      @accredited_bodies ||= provider.accredited_bodies.map do |ab|
        accredited_body(ab)
      end
    end

  private

    def accredited_body(provider_name:, provider_code:, description:)
      AccreditedBody.new(
        provider_name: provider_name,
        provider_code: provider_code,
        description: params_description(provider_code) || description,
      )
    end

    def params_description(provider_code)
      params[:accredited_bodies].to_h { |i| [i[:provider_code], i[:description]] }[provider_code] if params&.dig(:accredited_bodies).present?
    end

    def accrediting_provider_enrichments
      accredited_bodies.map do |accredited_body|
        {
          UcasProviderCode: accredited_body.provider_code,
          Description: accredited_body.description,
        }
      end
    end

    def compute_fields
      provider.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def new_attributes
      params.except(:accredited_bodies).merge(accrediting_provider_enrichments: accrediting_provider_enrichments)
    end

    def add_enrichment_errors
      accredited_bodies&.each_with_index do |accredited_body, _index|
        if accredited_body.invalid?
          errors.add :accredited_bodies, accredited_body.errors[:description].first
        end
      end
    end

    class AccreditedBody
      include ActiveModel::Model

      attr_accessor :provider_name, :provider_code, :description
    end
  end
end
