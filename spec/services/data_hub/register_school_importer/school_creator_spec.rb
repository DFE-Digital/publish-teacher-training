require "rails_helper"

RSpec.describe DataHub::RegisterSchoolImporter::SchoolCreator do
  subject(:creator) { described_class.new(provider:, urns:, row_number:) }

  let(:provider) { create(:provider) }
  let(:row_number) { 10 }

  describe "#call" do
    context "when GIAS school exists and site does not exist" do
      let(:urns) { %w[12345] }
      let!(:gias_school) { create(:gias_school, :open, urn: "12345", name: "Test School") }

      it "creates a new site and returns it in schools_added" do
        expect {
          @result = creator.call
        }.to change { provider.sites.count }.by(1)

        expect(@result.schools_added).to eq([{ urn: "12345", row: row_number }])
        expect(@result.ignored_urns).to be_empty

        site = provider.sites.find_by(urn: "12345")
        expect(site).not_to be_nil
        expect(site.location_name).to eq("Test School")
        expect(site.site_type).to eq("school")
        expect(site.added_via).to eq("register_import")
      end
    end

    context "when GIAS school does not exist" do
      let(:urns) { %w[99999] }

      it "does not create a site and returns ignored_urns with reason" do
        expect {
          @result = creator.call
        }.not_to(change { provider.sites.count })

        expect(@result.schools_added).to be_empty
        expect(@result.ignored_urns).to eq([{ urn: "99999", row: row_number, reason: "Not found in GIAS" }])
      end
    end

    context "when site already exists for provider" do
      let(:urns) { %w[12345] }
      let!(:gias_school) { create(:gias_school, :open, urn: "12345", name: "Test School") }

      before do
        create(:site, provider:, urn: "12345", location_name: "Existing School", site_type: :school)
      end

      it "does not create a new site and returns ignored_urns with reason" do
        expect {
          @result = creator.call
        }.not_to(change { provider.sites.count })

        expect(@result.schools_added).to be_empty
        expect(@result.ignored_urns).to eq([{ urn: "12345", row: row_number, reason: "Already exists for provider" }])
      end
    end

    context "when site save raises an error" do
      let!(:gias_school) { create(:gias_school, :open, urn: "12345", name: "Test School", town: "") }
      let(:urns) { %w[12345] }

      it "adds to school_errors and continues processing" do
        result = creator.call
        expect(result.schools_added).to be_empty
        expect(result.ignored_urns).to be_empty
        expect(result.school_errors.first[:urn]).to eq("12345")
        expect(result.school_errors.first[:row]).to eq(row_number)
        expect(result.school_errors.first[:error]).to be_present
      end
    end
  end

  describe "#create!" do
    let(:urns) { %w[12345] }
    let(:urn) { urns.first }
    let!(:gias_school) { create(:gias_school, :open, urn: "12345", name: "Test School") }

    it "assigns attributes and saves the site" do
      site = provider.sites.new(urn: "12345")
      expect(site).to receive(:assign_attributes).with(gias_school.school_attributes).and_call_original
      expect(site).to receive(:site_type=).with(Site.site_types[:school])
      expect(site).to receive(:save!).and_call_original

      creator.create!(site, gias_school)
    end

    context "when GIAS school has latitude and longitude" do
      let!(:gias_school) { create(:gias_school, :open, urn:, latitude: 52.6, longitude: -1.2) }

      it "copies lat/lng and does NOT enqueue geocoding" do
        expect {
          creator.call
        }.not_to have_enqueued_job(GeocodeJob).with("Site", kind_of(Integer))

        site = provider.reload.sites.find_by(urn:)
        expect(site.latitude).to eq(52.6)
        expect(site.longitude).to eq(-1.2)
        expect(site.added_via).to eq("register_import")
      end
    end

    context "when GIAS school lacks latitude and longitude" do
      let!(:gias_school) { create(:gias_school, :open, urn: urns.first, latitude: nil, longitude: nil) }

      it "does NOT copy lat/lng and DOES enqueue geocoding" do
        expect {
          creator.call
        }.to have_enqueued_job(GeocodeJob).with("Site", kind_of(Integer))

        site = provider.reload.sites.find_by(urn:)
        expect(site.latitude).to be_nil
        expect(site.longitude).to be_nil
        expect(site.skip_geocoding).not_to be(true)
      end
    end

    context "when only one coordinate is present" do
      let!(:gias_school) { create(:gias_school, :open, urn:, latitude: 51.5, longitude: nil) }

      it "does NOT copy lat/lng and DOES enqueue geocoding" do
        expect {
          creator.call
        }.to have_enqueued_job(GeocodeJob).with("Site", kind_of(Integer))

        site = provider.reload.sites.find_by(urn:)
        expect(site.latitude).to be_nil
        expect(site.longitude).to be_nil
        expect(site.skip_geocoding).not_to be(true)
      end
    end
  end
end
