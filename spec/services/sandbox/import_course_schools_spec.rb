# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sandbox::ImportCourseSchools do
  subject(:import) { described_class.call(course:, locations:) }

  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }
  let(:locations) { JSON.parse(file_fixture("publish_public_api/course_locations.json").read) }

  context "when the GIAS school is already in this environment" do
    let!(:gias_school) { create(:gias_school, urn: "133802", name: "University of Chester") }

    it "adds the school to the provider with the production code and links the course" do
      expect { import }.not_to change(GiasSchool, :count)

      provider_school = provider.schools.sole
      expect(provider_school).to have_attributes(gias_school:, site_code: "-")
      expect(course.schools.map(&:provider_school)).to eq([provider_school])
      expect(import).to have_attributes(schools_created: ["- (133802)"], gias_stubs: [], conflicts: [], uuid_clashes: [], schools_unlinked: [])
    end

    it "gives the provider school production's uuid" do
      import

      expect(provider.schools.sole.uuid).to eq("9118a484-d2b3-4b3d-a03a-d262cb451c01")
    end

    context "when production's uuid is already used here" do
      before { create(:provider_school, uuid: "9118a484-d2b3-4b3d-a03a-d262cb451c01") }

      it "gives the provider school a new uuid and reports it" do
        import

        expect(provider.schools.sole.uuid).not_to eq("9118a484-d2b3-4b3d-a03a-d262cb451c01")
        expect(import.uuid_clashes).to eq(["- (133802): uuid 9118a484-d2b3-4b3d-a03a-d262cb451c01 is already used here"])
      end
    end

    it "does nothing new when run again" do
      described_class.call(course:, locations:)

      expect { import }.not_to change(Provider::School, :count)
      expect(course.schools.count).to eq(1)
      expect(import).to have_attributes(schools_created: [], gias_stubs: [], conflicts: [])
    end
  end

  context "when the course has a school production no longer has" do
    let!(:gias_school) { create(:gias_school, urn: "133802") }
    let!(:old_school) do
      create(:provider_school, provider:, site_code: "Z", gias_school: create(:gias_school, urn: "999999"))
    end

    before { course.schools.create!(provider_school: old_school, gias_school: old_school.gias_school) }

    it "unlinks it from the course and reports it" do
      import

      expect(course.schools.reload.map(&:site_code)).to eq(["-"])
      expect(import.schools_unlinked).to eq(["Z (999999)"])
    end

    it "keeps the provider's school" do
      import

      expect(Provider::School.exists?(old_school.id)).to be(true)
    end

    it "unlinks nothing when run again" do
      described_class.call(course:, locations:)

      expect(import.schools_unlinked).to eq([])
    end
  end

  context "when the GIAS school is missing" do
    it "creates it from the production location" do
      expect { import }.to change(GiasSchool, :count).by(1)

      expect(GiasSchool.find_by(urn: "133802")).to have_attributes(
        name: "University of Chester",
        address1: "Parkgate Road",
        town: "Chester",
        county: "Cheshire",
        postcode: "CH1 4BJ",
        region_code: "north_west",
        latitude: 53.1986567225753,
        longitude: -2.898062705941234,
        status_code: "open",
      )
      expect(provider.schools.sole.site_code).to eq("-")
      expect(import.gias_stubs).to eq(%w[133802])
    end
  end

  context "when the provider already has a different main site" do
    let!(:other_main_site) { create(:provider_school, :main_site, provider:) }

    it "reports the conflict and leaves the course without that school" do
      expect { import }.not_to change(Provider::School, :count)

      expect(course.schools).to be_empty
      expect(import.conflicts).to eq(["- (133802): the provider already has a school with code -"])
    end

    context "when the course is linked to that main site" do
      before { course.schools.create!(provider_school: other_main_site, gias_school: other_main_site.gias_school) }

      it "keeps the link" do
        import

        expect(course.schools.reload.map(&:provider_school)).to eq([other_main_site])
        expect(import.schools_unlinked).to eq([])
      end
    end
  end

  context "when the provider already has the school under another code" do
    let!(:gias_school) { create(:gias_school, urn: "133802") }
    let!(:school_a) { create(:provider_school, provider:, site_code: "A", gias_school:) }

    before { course.schools.create!(provider_school: school_a, gias_school:) }

    it "adds it under production's code too and moves the course onto it" do
      import

      expect(provider.schools.pluck(:site_code)).to contain_exactly("A", "-")
      expect(course.schools.reload.map(&:site_code)).to eq(["-"])
      expect(import).to have_attributes(conflicts: [], schools_created: ["- (133802)"], schools_unlinked: ["A (133802)"])
    end
  end

  context "when production has the same school under two codes" do
    let!(:gias_school) { create(:gias_school, urn: "133802") }
    let(:locations) do
      location = JSON.parse(file_fixture("publish_public_api/course_locations.json").read).first
      [location, location.deep_merge("id" => "2", "attributes" => { "code" => "B", "uuid" => SecureRandom.uuid })]
    end

    it "adds both" do
      import

      expect(course.schools.reload.map(&:site_code)).to contain_exactly("-", "B")
      expect(import.conflicts).to eq([])
    end
  end
end
