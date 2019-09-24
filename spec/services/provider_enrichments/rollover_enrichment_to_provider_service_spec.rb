describe ProviderEnrichments::RolloverEnrichmentToProviderService do
  let(:service) { described_class.new }

  def duplicated_provider_enrichments(enrichment)
    enrichment.attributes.except(
      "id",
      "provider_id",
      "created_at",
      "updated_at",
      "status",
    )
  end

  context "Copying provider enrichment to a new provider" do
    let(:enrichment) { create(:provider_enrichment, provider: create(:provider)) }
    let(:new_provider) { create(:provider) }

    before do
      service.execute(enrichment: enrichment, new_provider: new_provider)
      new_provider.reload
    end

    it "Adds the enrichment to the new provider" do
      new_enrichment = new_provider.enrichments.first

      expect(new_enrichment.provider_id).to eq(new_provider.id)
      expect(duplicated_provider_enrichments(new_enrichment)).to eq(duplicated_provider_enrichments(enrichment))
    end

    it "Sets the last published timestamp of the copy to nil" do
      expect(new_provider.enrichments.first.last_published_at).to be_nil
    end

    it "Marks the enrichment as rolled over" do
      expect(new_provider.enrichments.first.rolled_over?).to be true
    end
  end
end
