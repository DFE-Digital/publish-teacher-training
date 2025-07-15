require "rails_helper"

RSpec.describe RegisterSchoolImporter::ImportSummary do
  subject(:summary) { described_class.new }

  let(:provider_code) { "BU1" }

  describe "#mark_provider_not_found" do
    it "adds a row to provider_not_found for the correct provider group" do
      summary.mark_provider_not_found(provider_code, 3)

      group = summary.groups.find { |g| g.provider_code == provider_code }

      expect(group).not_to be_nil
      expect(group.provider_not_found).to contain_exactly({ row: 3 })
    end
  end

  describe "#mark_ignored_schools" do
    let(:ignored) do
      [
        { urn: "123456", row: 2, reason: "Not found in GIAS" },
        { urn: "654321", row: 5, reason: "Already exists for provider" },
      ]
    end

    it "adds the ignored schools to the group" do
      summary.mark_ignored_schools(provider_code, ignored)

      group = summary.groups.find { |g| g.provider_code == provider_code }

      expect(group.ignored_schools).to match_array(ignored)
    end
  end

  describe "#mark_schools_added" do
    let(:added) do
      [
        { urn: "123456", row: 2 },
        { urn: "654321", row: 5 },
      ]
    end

    it "adds the schools added to the group" do
      summary.mark_schools_added(provider_code, added)

      group = summary.groups.find { |g| g.provider_code == provider_code }

      expect(group.schools_added).to match_array(added)
    end
  end

  describe "#meta" do
    before do
      summary.mark_provider_not_found("D39", 4)

      summary.mark_ignored_schools("XYZ", [
        { urn: "100001", row: 3, reason: "Not found in GIAS" },
        { urn: "100002", row: 3, reason: "Not found in GIAS" },
        { urn: "100003", row: 3, reason: "Already exists for provider" },
      ])

      summary.mark_schools_added("123", [
        { urn: "100004", row: 2 },
        { urn: "100005", row: 2 },
      ])
    end

    it "calculates total counts and returns expected structure" do
      meta = summary.meta

      expect(meta).to eq(
        schools_added_count: 2,
        providers_not_found_count: 1,
        providers_not_found_codes: %w[D39],
        schools_not_found_in_gias_count: 2,
        schools_not_found_in_gias_urns: %w[100001 100002],
        schools_already_exists_count: 1,
      )
    end
  end

  describe "#full_summary" do
    before do
      summary.mark_provider_not_found("BU", 2)
      summary.mark_ignored_schools("DEF", [{ urn: "111111", row: 4, reason: "Not found in GIAS" }])
      summary.mark_schools_added("XYZ", [{ urn: "222222", row: 5 }])
    end

    it "includes both meta and groups" do
      result = summary.full_summary

      expect(result).to have_key(:meta)
      expect(result).to have_key(:groups)

      expect(result[:groups].keys).to match_array(%w[BU DEF XYZ])
    end
  end
end
