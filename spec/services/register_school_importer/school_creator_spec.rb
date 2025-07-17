require "rails_helper"

RSpec.describe RegisterSchoolImporter::SchoolCreator do
  subject { described_class.new(provider:, urns:, row_number:) }

  let(:provider) { create(:provider) }
  let(:row_number) { 10 }

  describe "#call" do
    context "when GIAS school exists and site does not exist" do
      let(:urns) { %w[12345] }
      let!(:gias_school) { create(:gias_school, :open, urn: "12345", name: "Test School") }

      it "creates a new site and returns it in schools_added" do
        expect {
          @result = subject.call
        }.to change { provider.sites.count }.by(1)

        expect(@result.schools_added).to eq([{ urn: "12345", row: row_number }])
        expect(@result.ignored_urns).to be_empty

        site = provider.sites.find_by(urn: "12345")
        expect(site).not_to be_nil
        expect(site.location_name).to eq("Test School")
        expect(site.site_type).to eq("school")
      end
    end

    context "when GIAS school does not exist" do
      let(:urns) { %w[99999] }

      it "does not create a site and returns ignored_urns with reason" do
        expect {
          @result = subject.call
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
          @result = subject.call
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

      subject.create!(site, gias_school)
    end
  end
end
