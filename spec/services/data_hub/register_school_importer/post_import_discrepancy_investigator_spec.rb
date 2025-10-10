require "rails_helper"
require "csv"

RSpec.describe DataHub::RegisterSchoolImporter::PostImportDiscrepancyInvestigator, type: :service do
  subject(:investigator) do
    described_class.new(
      recruitment_cycle: provider.recruitment_cycle,
      csv_path: csv_path,
      provider_code: provider.provider_code,
    )
  end

  let!(:provider) do
    create(
      :provider,
      recruitment_cycle: RecruitmentCycle.current,
      provider_code: "12K",
    )
  end

  let!(:gias_one) { create(:gias_school, urn: "108852") }
  let!(:gias_two) { create(:gias_school, urn: "115046") }
  let!(:gias_three) { create(:gias_school, urn: "601996") }
  let!(:gias_four) { create(:gias_school, urn: "441668") }
  let!(:gias_extra) { create(:gias_school, urn: "999999") }

  let!(:site_one) { create(:site, provider: provider, urn: "108852", added_via: :register_import) }
  let!(:site_two) { create(:site, provider: provider, urn: "115046", added_via: :register_import) }
  let!(:site_three) { create(:site, provider: provider, urn: "601996", added_via: :register_import) }
  let!(:site_extra) { create(:site, provider: provider, urn: "999999", added_via: :register_import) }

  let(:csv_path) do
    file_fixture("register_school_importer/schools.csv")
  end

  describe "#call" do
    before { investigator.call }

    it "collects all unique URNs from CSV for provider appearing in multiple rows (B38 and D39)" do
      expected_urns = %w[108852 115046 601996 441668 985750 998363]
      expect(investigator.csv_urns).to match_array expected_urns
    end

    it "collects URNs from database sites with register_import added_via" do
      expect(investigator.db_urns).to match_array %w[108852 115046 601996 999999]
    end

    it "filters to only URNs that exist in GIAS" do
      expect(investigator.gias_urns).to match_array %w[108852 115046 601996 441668 999999]
    end

    it "computes CSV-only URNs (in CSV but not in database)" do
      expect(investigator.investigation_results[:csv_only]).to match_array %w[441668 985750 998363]
    end

    it "computes DB-only URNs (in database but not in CSV)" do
      expect(investigator.investigation_results[:db_only]).to match_array %w[999999]
    end

    it "computes successfully imported URNs (in both CSV and database)" do
      expect(investigator.investigation_results[:both_urns]).to match_array %w[108852 115046 601996]
    end

    it "computes invalid CSV URNs (no corresponding GIAS record)" do
      expect(investigator.investigation_results[:invalid_csv_urns]).to match_array %w[985750 998363]
    end

    it "detects valid CSV URNs not imported (have GIAS but not in database)" do
      expect(investigator.investigation_results[:missing_valid_urns]).to eq %w[441668]
    end

    it "detects extra DB URNs not present in CSV (valid GIAS but not in original import)" do
      expect(investigator.investigation_results[:extra_db_urns]).to eq %w[999999]
    end

    it "reports correct counts for all categories" do
      results = investigator.investigation_results
      expect(results[:csv_total]).to eq 6
      expect(results[:db_total]).to eq 4
      expect(results[:csv_valid_gias]).to eq 4
      expect(results[:db_valid_gias]).to eq 4
      expect(results[:both_count]).to eq 3
      expect(results[:missing_valid_urns_count]).to eq 1
      expect(results[:invalid_csv_urns_count]).to eq 2
      expect(results[:extra_db_urns_count]).to eq 1
    end
  end

  describe "#export_to_csv" do
    before { investigator.call }

    it "writes CSV file with header row plus one row per unique URN" do
      path = investigator.export_to_csv(Rails.root.join("tmp/test_export.csv"))
      data = CSV.read(path)

      header = data.shift
      expect(header).to eq %w[URN Status GIAS_School_Name In_CSV In_Database Valid_GIAS]
      expect(data.length).to eq 7

      row_441668 = data.detect { |r| r.first == "441668" }
      expect(row_441668[1]).to eq "Missing from Database"

      row_985750 = data.detect { |r| r.first == "985750" }
      expect(row_985750[1]).to eq "Invalid GIAS URN"

      row_999999 = data.detect { |r| r.first == "999999" }
      expect(row_999999[1]).to eq "Extra in Database"

      row_108852 = data.detect { |r| r.first == "108852" }
      expect(row_108852[1]).to eq "Successfully Imported"
    end

    it "includes GIAS school names where available" do
      path = investigator.export_to_csv(Rails.root.join("tmp/test_export_with_names.csv"))
      data = CSV.read(path)

      data.shift

      row_with_gias = data.detect { |r| r.first == "108852" }
      expect(row_with_gias[2]).to eq gias_one.name

      row_without_gias = data.detect { |r| r.first == "985750" }
      expect(row_without_gias[2]).to be_nil
    end
  end

  context "when provider has no sites" do
    subject(:investigator_empty) do
      described_class.new(
        recruitment_cycle: empty_provider.recruitment_cycle,
        csv_path: csv_path,
        provider_code: "EMPTY",
      )
    end

    let!(:empty_provider) do
      create(
        :provider,
        recruitment_cycle: RecruitmentCycle.current,
        provider_code: "EMPTY",
      )
    end

    it "handles providers with no imported sites gracefully" do
      investigator_empty.call

      expect(investigator_empty.csv_urns).to be_empty
      expect(investigator_empty.db_urns).to be_empty
      expect(investigator_empty.investigation_results[:csv_total]).to eq 0
      expect(investigator_empty.investigation_results[:db_total]).to eq 0
    end
  end
end
