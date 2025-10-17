require "rails_helper"

RSpec.describe DataHub::BlankCoordinatesBackfill::Query, type: :service do
  let(:recruitment_cycle) { RecruitmentCycle.current }
  let(:query) { described_class.new(recruitment_cycle) }

  describe "#call" do
    let!(:provider) { create(:provider, recruitment_cycle:) }

    context "with sites needing geocoding" do
      let!(:site_without_coords) { create(:site, latitude: nil, longitude: nil, provider:) }
      let!(:site_with_coords) { create(:site, latitude: 51.5, longitude: -0.1, provider:) }
      let!(:discarded_site) { create(:site, latitude: nil, longitude: nil, provider:, discarded_at: 1.day.ago) }

      it "returns only kept sites without coordinates" do
        results = query.call
        site_results = results.select { |r| r[:type] == "Site" }

        expect(site_results.size).to eq(1)
        expect(site_results.first[:id]).to eq(site_without_coords.id)
      end
    end

    context "with GIAS schools needing geocoding" do
      let!(:school_missing_lat) { create(:gias_school, latitude: nil, longitude: -0.1) }
      let!(:school_missing_lng) { create(:gias_school, latitude: 51.5, longitude: nil) }
      let!(:school_missing_both) { create(:gias_school, latitude: nil, longitude: nil) }
      let!(:school_with_coords) { create(:gias_school, latitude: 51.5, longitude: -0.1) }

      it "returns schools missing latitude or longitude" do
        results = query.call
        school_results = results.select { |r| r[:type] == "GiasSchool" }

        expect(school_results.size).to eq(3)
        expect(school_results.map { |r| r[:id] }).to contain_exactly(school_missing_lat.id, school_missing_lng.id, school_missing_both.id)
      end
    end

    context "with mixed records" do
      let!(:site_no_coords) { create(:site, latitude: nil, longitude: nil, provider:) }
      let!(:school_no_coords) { create(:gias_school, latitude: nil, longitude: nil) }

      it "returns both sites and schools needing backfill" do
        results = query.call

        expect(results.size).to eq(2)
        expect(results).to include(
          { type: "Site", id: site_no_coords.id },
          { type: "GiasSchool", id: school_no_coords.id },
        )
      end
    end

    context "when no records need geocoding" do
      let!(:site_with_coords) { create(:site, latitude: 51.5, longitude: -0.1, provider:) }
      let!(:school_with_coords) { create(:gias_school, latitude: 51.5, longitude: -0.1) }

      it "returns empty array" do
        expect(query.call).to eq([])
      end
    end
  end

  describe "#total_count" do
    let!(:provider) { create(:provider, recruitment_cycle:) }
    let!(:sites) { create_list(:site, 3, latitude: nil, longitude: nil, provider:) }
    let!(:schools) { create_list(:gias_school, 2, latitude: nil, longitude: nil) }

    it "returns total count of all records needing geocoding" do
      expect(query.total_count).to eq(5)
    end

    context "when no records need geocoding" do
      let!(:sites) { [] }
      let!(:schools) { [] }

      it "returns zero" do
        expect(query.total_count).to eq(0)
      end
    end
  end

  describe "recruitment cycle filtering" do
    let(:other_cycle) { create(:recruitment_cycle, year: "2022") }
    let(:other_provider) { create(:provider, recruitment_cycle: other_cycle) }

    let!(:site_in_cycle) { create(:site, latitude: nil, longitude: nil, provider: create(:provider, recruitment_cycle:)) }
    let!(:site_other_cycle) { create(:site, latitude: nil, longitude: nil, provider: other_provider) }

    it "only returns sites from specified recruitment cycle" do
      results = query.call
      site_results = results.select { |r| r[:type] == "Site" }

      expect(site_results.size).to eq(1)
      expect(site_results.first[:id]).to eq(site_in_cycle.id)
    end

    it "returns all GIAS schools regardless of cycle" do
      school = create(:gias_school, latitude: nil, longitude: nil)
      results = query.call
      school_results = results.select { |r| r[:type] == "GiasSchool" }

      expect(school_results.map { |r| r[:id] }).to include(school.id)
    end
  end
end
