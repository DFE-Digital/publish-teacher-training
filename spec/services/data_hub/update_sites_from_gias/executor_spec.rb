require "rails_helper"

RSpec.describe DataHub::UpdateSitesFromGias::Executor do
  let(:recruitment_cycle) { create(:recruitment_cycle, year: "2025") }
  let(:provider) { create(:provider, recruitment_cycle: recruitment_cycle) }

  let!(:site_one) do
    create(:site, provider:, urn: "41333", location_name: "A", address1: "Old Addr")
  end

  let!(:gias_one) do
    create(:gias_school, urn: "41333", name: "A", address1: "New Addr")
  end

  let!(:site_two) do
    create(:site, provider:, urn: "41334", location_name: "B", latitude: 50.0, address1: "Addr")
  end

  let!(:gias_two) do
    create(:gias_school, urn: "41334", name: "B", latitude: 51.5, address1: "Addr")
  end

  describe "real updater" do
    subject(:summary) do
      described_class.new(recruitment_cycle: recruitment_cycle).execute
    end

    it "updates only necessary fields and builds both summaries" do
      expect { summary }
        .to change { site_one.reload.address1 }
        .from("Old Addr").to("New Addr")
        .and change { site_two.reload.latitude }
        .from(50.0).to(51.5)

      full = summary.full_summary.deep_symbolize_keys
      short = summary.short_summary.deep_symbolize_keys

      expect(full[:site_updates].size).to eq(2)
      expect(full[:site_updates].map { |x| x[:id] }).to contain_exactly(site_one.id, site_two.id)
      expect(full[:site_updates].find { |u| u[:id] == site_one.id }[:changes].keys).to include(:address1)
      expect(short[:address1]).to eq(1)
      expect(short[:latitude]).to eq(1)
      expect(short[:updated_total_count]).to eq(2)
      expect(short[:updater_class]).to include("SiteUpdater")
    end
  end

  describe "dry run updater" do
    subject(:summary) do
      described_class.new(
        recruitment_cycle:,
        updater_class: DataHub::UpdateSitesFromGias::DryRunSiteUpdater,
      ).execute
    end

    it "does not persist changes but builds the correct summary" do
      expect {
        summary
      }.not_to(change { [site_one.reload.address1, site_two.reload.latitude] })

      full_summary = summary.full_summary.deep_symbolize_keys
      short_summary = summary.short_summary.deep_symbolize_keys

      ids = full_summary[:site_updates].map { |u| u[:id] }
      expect(ids).to contain_exactly(site_one.id, site_two.id)
      expect(short_summary[:updater_class]).to include("DryRun")
    end
  end

  describe "summary keys" do
    subject(:summary) do
      described_class.new(recruitment_cycle: recruitment_cycle).execute
    end

    it "produces a full_summary with before/after for each changed field" do
      full_summary = summary.full_summary.deep_symbolize_keys
      change = full_summary[:site_updates].find { |u| u[:id] == site_one.id }[:changes]
      expect(change.keys).to include(:address1)
      expect(change[:address1]).to eq(before: "Old Addr", after: "New Addr")
    end
  end

  describe "error handling" do
    let(:bombing_updater_class) do
      Class.new do
        def initialize(site:, gias_school:); end
        def call = raise("exploded!")
      end
    end

    it "marks the summary as failed if an error is raised" do
      expect {
        described_class.new(
          recruitment_cycle: recruitment_cycle,
          updater_class: bombing_updater_class,
        ).execute
      }.to raise_error("exploded!")

      expect(DataHub::UpdateSitesFromGiasProcessSummary.last.failed?).to be true
    end
  end
end
