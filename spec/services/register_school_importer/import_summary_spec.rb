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

  describe "#mark_school_errors" do
    it "adds all school errors and tracks urns and count for the group" do
      school_errors = [
        { urn: "999111", row: 7, error: "Save failed" },
        { urn: "999112", row: 8, error: "Validation failed" },
      ]
      summary.mark_school_errors(provider_code, school_errors)

      group = summary.groups.find { |g| g.provider_code == provider_code }

      expect(group.school_errors).to match_array(school_errors)
      expect(group.school_errors_urns).to match_array(%w[999111 999112])
      expect(group.school_errors_count).to eq(2)
    end

    it "initializes error tracking if not present" do
      school_errors = [{ urn: "900001", row: 2, error: "Some error" }]
      summary.mark_school_errors(provider_code, school_errors)
      summary.mark_school_errors(provider_code, [])

      group = summary.groups.find { |g| g.provider_code == provider_code }

      expect(group.school_errors).to eq(school_errors)
      expect(group.school_errors_urns).to eq(%w[900001])
      expect(group.school_errors_count).to eq(1)
    end

    it "does nothing if an empty array is passed" do
      expect {
        summary.mark_school_errors(provider_code, [])
      }.not_to(change { summary.groups.find { |g| g.provider_code == provider_code }&.school_errors })
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

      summary.mark_school_errors("ERR", [
        { urn: "200001", row: 9, error: "Validation failed" },
        { urn: "200002", row: 9, error: "Transaction error" },
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
        school_errors_count: 2,
        school_errors_urns: %w[200001 200002],
      )
    end
  end

  describe "#full_summary" do
    before do
      summary.mark_provider_not_found("BU", 2)
      summary.mark_ignored_schools("DEF", [{ urn: "111111", row: 4, reason: "Not found in GIAS" }])
      summary.mark_schools_added("XYZ", [{ urn: "222222", row: 5 }])
      summary.mark_school_errors("DEF", [{ urn: "500005", row: 8, error: "Fail" }])
    end

    it "includes both meta and groups" do
      result = summary.full_summary

      expect(result).to have_key(:meta)
      expect(result).to have_key(:groups)

      expect(result[:groups].keys).to match_array(%w[BU DEF XYZ])

      def_group = result[:groups]["DEF"]
      expect(def_group.school_errors).to eq([{ urn: "500005", row: 8, error: "Fail" }])
      expect(def_group.school_errors_urns).to eq(%w[500005])
      expect(def_group.school_errors_count).to eq(1)
    end
  end
end
