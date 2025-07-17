require "rails_helper"

RSpec.describe RegisterSchoolImporter::Importer do
  subject { described_class.new(recruitment_cycle:, csv_path:) }

  let(:recruitment_cycle) { create(:recruitment_cycle) }
  let(:csv_path) { file_fixture("register_school_importer/schools.csv") }

  before do
    create(:provider, :accredited_provider, recruitment_cycle:, provider_code: "133")
    create(:provider, :accredited_provider, recruitment_cycle:, provider_code: "B38")
    create(:provider, :accredited_provider, recruitment_cycle:, provider_code: "D39")
    create(:provider, recruitment_cycle:, provider_code: "12K")
    create(:provider, recruitment_cycle:, provider_code: "13S")
    create(:provider, recruitment_cycle:, provider_code: "1A3")

    create(:gias_school, :open, urn: "972674")
    create(:gias_school, :open, urn: "511462")
    create(:gias_school, :open, urn: "108852")
    create(:gias_school, :open, urn: "298561", town: "")

    # 115046 and 601996 missing (simulate "Not found in GIAS")
    # 50494 and 230153 missing (simulate "Not found in GIAS")
    create(:gias_school, :open, urn: "441668")
    create(:gias_school, :open, urn: "985750")
    create(:gias_school, :open, urn: "998363")
    create(:gias_school, :open, urn: "129676")
  end

  context "when all schools are created for a provider" do
    it "records all schools as created and none as ignored" do
      summary = subject.call
      group_133 = summary.groups.find { |g| g.provider_code == "133" }

      expect(group_133.provider_not_found).to be_empty
      expect(group_133.ignored_schools).to be_empty
      expect(group_133.schools_added).to contain_exactly({ urn: "972674", row: 2 }, { urn: "511462", row: 2 })
    end
  end

  context "when some schools are ignored for not being in GIAS and some already exist" do
    before do
      provider = Provider.find_by(provider_code: "12K")

      create(:site, provider:, urn: "108852")
    end

    it "records ignored schools with correct reasons and created schools" do
      summary = subject.call
      group_12k = summary.groups.find { |g| g.provider_code == "12K" }

      expect(group_12k.provider_not_found).to be_empty
      expect(group_12k.schools_added).to contain_exactly({ urn: "441668", row: 4 }, { urn: "985750", row: 4 }, { urn: "998363", row: 4 })
      expect(group_12k.ignored_schools).to contain_exactly({ urn: "115046", row: 3, reason: "Not found in GIAS" }, { urn: "601996", row: 3, reason: "Not found in GIAS" }, { urn: "108852", row: 3, reason: "Already exists for provider" })
    end
  end

  context "when some schools are ignored for not being in GIAS" do
    it "records ignored schools with correct reasons and created schools" do
      summary = subject.call
      group_13s = summary.groups.find { |g| g.provider_code == "13S" }

      expect(group_13s.provider_not_found).to be_empty
      expect(group_13s.schools_added).to eq([{ urn: "129676", row: 5 }])
      expect(group_13s.ignored_schools).to eq([{ urn: "50494", row: 5, reason: "Not found in GIAS" }])
    end
  end

  context "when all schools are ignored for not being in GIAS" do
    it "records all schools as ignored with correct reason" do
      summary = subject.call
      group_1a3 = summary.groups.find { |g| g.provider_code == "1A3" }

      expect(group_1a3.provider_not_found).to be_empty
      expect(group_1a3.schools_added).to be_empty
      expect(group_1a3.ignored_schools).to eq([{ urn: "230153", row: 6, reason: "Not found in GIAS" }])
    end
  end

  context "when provider is not found" do
    before do
      Provider.where(provider_code: "1A3").delete_all
    end

    it "records provider not found and no schools processed" do
      summary = subject.call
      group_d39 = summary.groups.find { |g| g.provider_code == "1A3" }

      expect(group_d39.provider_not_found).to eq([{ row: 6 }])
      expect(group_d39.schools_added).to be_empty
      expect(group_d39.ignored_schools).to be_empty
    end
  end

  context "when a site fails to save for a specific urn" do
    it "records the school error but continues processing other schools" do
      summary = subject.call
      provider_group = summary.groups.find { |g| g.provider_code == "1A3" }

      expect(provider_group.school_errors).to include(
        a_hash_including(
          urn: "298561",
          row: 6,
          error: a_string_matching(/Validation failed: Town or city Enter a town or city/),
        ),
      )
      expect(provider_group.school_errors_urns).to include("298561")
      expect(provider_group.school_errors_count).to eq(1)
    end
  end
end
