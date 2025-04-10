# frozen_string_literal: true

class BackfillProviderPartnerships < ActiveRecord::Migration[8.0]
  def up
    # Generate a hash with the keys being the provider code of training providers that have open published courses
    # and the value being an array of the ratifying provider codes for which a provider partnership does not exist
    #
    #
    # For all Training providers in the current cycle, collect the ratifying provider codes for their published courses.
    # Ignore training providers who have no courses ratified
    #
    # Find the ratifying provider codes that don't appear in the training providers partnerships
    # Eg:
    #
    # {
    #  "2T1"=>["D87", "2BA"],
    #  ...
    #  }
    #
    partners = Provider.where(accredited: false).in_current_cycle.filter_map.with_object({}) do |provider, coll|
      # Collect all the ratifying provider codes of this training provider
      ratifying_provider_codes = provider.courses.published.collect(&:accredited_provider_code).compact.uniq
      # Collect all the accredited partner provider codes of this training provider
      partnership_codes = provider.accrediting_provider_enrichments&.map(&:UcasProviderCode)&.compact&.uniq

      # # Ignore this provider if none of their published courses are ratified
      next if ratifying_provider_codes.blank?

      # Find the ratifying provider codes that where there is not partnership
      missing_partnerships = ratifying_provider_codes - partnership_codes

      next if missing_partnerships.blank?

      coll[provider.provider_code] = missing_partnerships
    end

    # Iterate over the generated hash and create the missing provider partnerships
    partners.each do |training_code, accredited_codes|
      training_provider = Provider.in_current_cycle.find_by(provider_code: training_code)

      accredited_codes.each do |accredited_code|
        accredited_provider = Provider.in_current_cycle.find_by(provider_code: accredited_code)

        next if accredited_provider.nil?

        train_with_us = accredited_provider.train_with_us || ""

        # If train_with_us is more than 100 words, it will be invalid.
        # When it is more than 100 words we take the first paragraph.
        # If the first paragraph is more than 100 words, we take the first sentence.
        # We fall back to empty string.
        first_paragraph   = train_with_us.split("\r\n\r\n").first
        first_line        = train_with_us.split("\r\n").first
        first_sentence    = train_with_us[/[^.]*\./]
        text              = [train_with_us, first_paragraph, first_line, first_sentence]
        description       = text.find { it.scan(/\S+/).size <= 100 } || ""

        training_provider.accrediting_provider_enrichments ||= []

        enrichment = AccreditingProviderEnrichment.new(UcasProviderCode: accredited_code, Description: description)

        training_provider.accrediting_provider_enrichments << enrichment
        training_provider.save
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
