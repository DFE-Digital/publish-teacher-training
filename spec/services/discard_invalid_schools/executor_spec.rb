require "rails_helper"

RSpec.describe DiscardInvalidSchools::Executor do
  subject(:executor) { described_class.new(year:, discarder_class:) }

  let(:recruitment_cycle) { RecruitmentCycle.current }
  let(:year) { recruitment_cycle.year }
  let!(:provider) { create(:provider, recruitment_cycle:) }

  let!(:site_no_urn) { create(:site, provider:, urn: nil, location_name: "Random School") }
  let!(:site_invalid_urn) { create(:site, provider:, urn: "12345", location_name: "Some School") }

  before do
    allow(DiscardInvalidSchools::SiteFilter).to receive(:filter).and_call_original
    allow(DataHub::DiscardInvalidSchoolsProcessSummary).to receive(:create!).and_call_original
  end

  shared_examples "a successful execution" do
    before { executor.execute }

    it "creates a DataHub summary" do
      summary = DataHub::DiscardInvalidSchoolsProcessSummary.last
      expect(summary).to be_present
      expect(summary.short_summary["discarded_total_count"]).to eq(2)
    end
  end

  context "with real discarder" do
    let(:discarder_class) { DiscardInvalidSchools::SiteDiscarder }

    it_behaves_like "a successful execution"

    it "actually discards the sites" do
      expect {
        executor.execute
      }.to change { Site.discarded.count }.by(2)
    end
  end

  context "with dry run discarder" do
    let(:discarder_class) { DiscardInvalidSchools::DryRunSiteDiscarder }

    it_behaves_like "a successful execution"

    it "does NOT discard the sites" do
      expect {
        executor.execute
      }.not_to(change { Site.discarded.count })
    end
  end
end
