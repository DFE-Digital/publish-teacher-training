require "rails_helper"

RSpec.describe DataHub::Rollover::StudySiteCodeOrchestrator, type: :service do
  let(:new_provider) { create(:provider) }
  let(:provider) { create(:provider) }
  let(:site_a) { build(:site, :study_site, code: "A1", provider:) }
  let(:site_b) { build(:site, :study_site, code: "B2", provider:) }

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

    context "when target already has some codes but source codes are unique" do
      let(:sites_to_copy) { [site_a, site_b] }

      before do
        create(:site, :study_site, provider: new_provider, code: "A1")
      end

      it "returns the original codes unchanged" do
        assignments = described_class.new(
          target_provider: new_provider,
          sites_to_copy: sites_to_copy,
        ).call

        expect(assignments.map { |a| a[:code] }).to contain_exactly("A1", "B2")
      end
    end

    context "when sites_to_copy include duplicate codes" do
      let(:first_dup) { build(:site, :study_site, code: "X9", provider:) }
      let(:second_dup) { build(:site, :study_site, code: "X9", provider:) }
      let(:sites_to_copy) { [first_dup, second_dup] }

      it "preserves the first code and generates a new code for the second" do
        assignments = described_class.new(
          target_provider: new_provider,
          sites_to_copy: sites_to_copy,
        ).call

        codes = assignments.map { |a| a[:code] }
        expect(codes.first).to eq("X9")
        expect(codes.second).not_to eq("X9")
        expect(codes.uniq.size).to eq(2)
      end

      it "selects the new code from DESIRABLE_CODES first" do
        assignments = described_class.new(
          target_provider: new_provider,
          sites_to_copy: sites_to_copy,
        ).call

        new_code = assignments.second[:code]
        expect(Site::DESIRABLE_CODES).to include(new_code)
      end
    end

    context "when all POSSIBLE_CODES are present on target" do
      let(:sites_to_copy) { [build(:site, :study_site, code: "ZZ", provider:)] }
      let(:mock_sites) { double(pluck: Site::POSSIBLE_CODES) }
      let(:mock_study_sites) { double(pluck: []) }

      before do
        allow(new_provider).to receive_messages(sites: mock_sites, study_sites: mock_study_sites)
      end

      it "keeps the original code when it's outside POSSIBLE_CODES" do
        assignments = described_class.new(
          target_provider: new_provider,
          sites_to_copy: sites_to_copy,
        ).call

        expect(assignments.first[:code]).to eq("ZZ")
      end
    end
  end
end
