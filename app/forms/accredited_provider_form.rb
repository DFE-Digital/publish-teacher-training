# frozen_string_literal: true

class AccreditedProviderForm < Form
  delegate :provider_name, to: :accredited_provider

  FIELDS = %i[
    description
    accredited_provider_id
  ].freeze

  attr_accessor(*FIELDS)

  validates :description, presence: true, words_count: { maximum: 100, message: :too_long }

  alias compute_fields new_attributes

  def accredited_provider
    @accredited_provider ||= Provider.find(accredited_provider_id)
  end

  private

  def assign_attributes_to_model
    model.accrediting_provider_enrichments = [] if model.accrediting_provider_enrichments.nil?

    accrediting_provider_enrichment = model.accrediting_provider_enrichments.find { |enrichment| enrichment.UcasProviderCode == accredited_provider.provider_code }

    if accrediting_provider_enrichment
      accrediting_provider_enrichment.Description = description
    else
      model.accrediting_provider_enrichments << enrichment_params
    end
  end

  def enrichment_params
    AccreditingProviderEnrichment.new(
      {
        UcasProviderCode: accredited_provider.provider_code,
        Description: description
      }
    )
  end

  def after_save
    accredited_provider.users.each do |user|
      ::Users::OrganisationMailer.added_as_an_organisation_to_training_partner(
        recipient: user,
        provider: model,
        accredited_provider:
      ).deliver_later
    end
  end
end
