require "rails_helper"

RSpec.describe DataHub::Rollover::StudySiteCodeOrchestrator, type: :service do
  let(:new_provider) { create(:provider) }
  let(:site_a)       { build(:site, :study_site, code: "A1", provider: provider) }
  let(:site_b)       { build(:site, :study_site, code: "B2", provider: provider) }
  let(:provider)     { create(:provider) }

  describe "#call" do
    context "when no duplicates and no existing codes on target" do
      let(:sites_to_copy) { [site_a, site_b] }

      it "returns each site with its original code" do
        assignments = described_class.new(
          target_provider: new_provider,
          sites_to_copy: sites_to_copy,
        ).call

        expect(assignments.map { |a| a[:site] }).to contain_exactly(site_a, site_b)
        expect(assignments.map { |a| a[:code] }).to contain_exactly("A1", "B2")
      end
    end

    context "when target already has some codes" do
      before do
        create(:site, :study_site, provider: new_provider, code: "A1")
      end

      let(:sites_to_copy) { [site_a, site_b] }

      it "generates a new code for the conflicting site and keeps the other unchanged" do
        assignments = described_class.new(
          target_provider: new_provider,
          sites_to_copy: sites_to_copy,
        ).call

        codes = assignments.map { |a| a[:code] }
        expect(codes).to include("B2") # unchanged
        expect(codes).to include(match(/\A[A-Z0-9-]\z/)) # new single‐character code for A1 conflict
        expect(codes.uniq.size).to eq(2) # both unique
      end
    end

    context "when sites_to_copy include duplicate codes" do
      let(:first_duplicate_site)  { build(:site, :study_site, code: "X9", provider: provider) }
      let(:second_duplicate_site) { build(:site, :study_site, code: "X9", provider: provider) }
      let(:sites_to_copy) { [first_duplicate_site, second_duplicate_site] }

      it "preserves first code and generates a new code for the second" do
        assignments = described_class.new(
          target_provider: new_provider,
          sites_to_copy: sites_to_copy,
        ).call

        codes = assignments.map { |a| a[:code] }
        expect(codes.first).to eq("X9")
        expect(codes.second).not_to eq("X9")
        expect(codes.uniq.size).to eq(2)
      end

      it "generates codes from DESIRABLE_CODES first" do
        assignments = described_class.new(
          target_provider: new_provider,
          sites_to_copy: sites_to_copy,
        ).call

        new_code = assignments.second[:code]
        expect(Site::DESIRABLE_CODES).to include(new_code)
      end
    end

    context "when all POSSIBLE_CODES are present on target" do
      let(:mock_sites_relation) { double("Sites") }
      let(:site) { build(:site, :study_site, code: "ZZ", provider: provider) }
      let(:mock_study_sites_relation) { double("StudySites") }

      before do
        codes = Site::POSSIBLE_CODES
        allow(mock_sites_relation).to receive(:pluck).with(:code).and_return(codes)
        allow(new_provider).to receive_messages(sites: mock_sites_relation, study_sites: mock_study_sites_relation)
        allow(mock_study_sites_relation).to receive(:pluck).with(:code).and_return([])
      end

      it "keeps the original code when it's not in POSSIBLE_CODES" do
        assignments = described_class.new(
          target_provider: new_provider,
          sites_to_copy: [site],
        ).call

        expect(assignments.first[:code]).to eq("ZZ")
      end
    end
  end
end
