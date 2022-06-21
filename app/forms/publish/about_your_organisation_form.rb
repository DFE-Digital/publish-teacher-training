module Publish
  class AboutYourOrganisationForm < BaseProviderForm
    validates :train_with_us, presence: { message: "Enter details about training with you" }, if: :train_with_us_changed?
    validates :train_with_disability, presence: { message: "Enter details about training with a disability" }, if: :train_with_disability_changed?

    validates :train_with_us, words_count: { maximum: 250, message: "Reduce the word count for training with you" }
    validates :train_with_disability, words_count: { maximum: 250, message: "Reduce the word count for training with disabilities and other needs" }

    validate :add_enrichment_errors

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

    def train_with_us_changed?
      changed?(:train_with_us)
    end

    def train_with_disability_changed?
      changed?(:train_with_disability)
    end

    def changed?(attribute)
      public_send(attribute) != provider.public_send(attribute)
    end

    def accredited_body(provider_name:, provider_code:, description:)
      AccreditedBody.new(
        provider_name:,
        provider_code:,
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
      params.except(:accredited_bodies).merge(accrediting_provider_enrichments:)
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
      validates :description, words_count: { maximum: 100, message: lambda do |object, _data|
        "Reduce the word count for #{object.provider_name}"
      end }

      attr_accessor :provider_name, :provider_code, :description
    end
  end
end
