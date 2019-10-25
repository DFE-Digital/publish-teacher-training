class CopyLatestProviderEnrichmentDataToProvider < ActiveRecord::Migration[6.0]
  def up
    say_with_time "copy provider enrichment to provider" do
      enrichment_fields = %w[train_with_us
                             train_with_disability
                             accrediting_provider_enrichments
                             last_published_at]

      contact_fields = %w[email
                          telephone
                          address1
                          address2
                          address3
                          address4
                          postcode
                          region_code
                          website]

      Provider.includes(:enrichments, :recruitment_cycle).each do |provider|
        latest_updated_at = provider.enrichments.max_by { |e| [e.updated_at, e.id] }

        if latest_updated_at.present?
          enrichment_data = latest_updated_at.attributes.slice(
            *enrichment_fields,
            *contact_fields,
          )

          provider.update(enrichment_data)
        end
      end
    end
  end

  def down
    # There is no down as it may cause data loss
  end
end
