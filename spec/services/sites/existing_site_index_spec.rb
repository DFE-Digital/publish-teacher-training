# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sites::ExistingSiteIndex do
  let(:provider) { create(:provider) }
  let(:other_provider) { create(:provider) }

  describe "school sites" do
    subject(:index) { described_class.for(provider:, site_type: :school) }

    let!(:site) { create(:site, provider:, urn: "123456", code: "A") }

    it "recognises a site with the same URN and code" do
      expect(index).to be_already_copied(build(:site, urn: " 123456 ", code: "A"))
    end

    it "does not recognise a site with a different URN" do
      expect(index).not_to be_already_copied(build(:site, urn: "654321", code: "A"))
    end

    # A provider can hold one URN twice - a main site and an ordinary school
    # site, since the backfill matches main sites to GIAS by postcode. They are
    # separate entries, and the copiers resolve a source site to its copy by
    # code, so conflating them would strand a course's site placement.
    it "does not recognise a site with the same URN at a different code" do
      expect(index).not_to be_already_copied(build(:site, urn: "123456", code: "Z"))
    end

    it "does not recognise a site belonging to another provider" do
      other_index = described_class.for(provider: other_provider, site_type: :school)

      expect(other_index).not_to be_already_copied(site)
    end

    it "does not recognise a discarded site" do
      site.discard

      expect(index).not_to be_already_copied(site)
    end

    it "does not recognise a study site with the same URN" do
      expect(index).not_to be_already_copied(build(:site, :study_site, urn: "123456"))
    end

    context "when the site has no URN" do
      let!(:site) { create(:site, :main_site, provider:) }

      it "matches it on its code" do
        expect(index).to be_already_copied(build(:site, :main_site))
      end

      it "does not recognise a URN-less site with a different code" do
        expect(index).not_to be_already_copied(build(:site, urn: nil, code: "Q"))
      end

      # Main sites carry both in the real data, and Site.with_available_gias_school
      # is the only place that tells them apart.
      it "treats a blank URN the same as a missing one" do
        expect(index).to be_already_copied(build(:site, :main_site, urn: " "))
      end
    end

    it "does not let a site with a URN mask a URN-less site sharing its code" do
      expect(index).not_to be_already_copied(build(:site, urn: nil, code: site.code))
    end
  end

  describe "study sites" do
    subject(:index) { described_class.for(provider:, site_type: :study_site) }

    let!(:study_site) { create(:site, :study_site, provider:, location_name: "Trumpington Campus", urn: "123456") }

    it "recognises a study site with the same location name" do
      expect(index).to be_already_copied(build(:site, :study_site, location_name: " trumpington campus ", urn: nil))
    end

    it "recognises a study site with the same URN" do
      expect(index).to be_already_copied(build(:site, :study_site, location_name: "Somewhere else", urn: "123456"))
    end

    it "does not recognise a study site with a different location name and URN" do
      expect(index).not_to be_already_copied(build(:site, :study_site, location_name: "Somewhere else", urn: "654321"))
    end

    it "does not recognise a study site with no URN and a different location name" do
      expect(index).not_to be_already_copied(build(:site, :study_site, location_name: "Somewhere else", urn: nil))
    end

    it "does not recognise a school site with the same location name" do
      expect(index).not_to be_already_copied(build(:site, location_name: study_site.location_name))
    end

    it "does not recognise a discarded study site" do
      study_site.discard

      expect(index).not_to be_already_copied(study_site)
    end
  end

  it "does not load the provider's sites association" do
    create(:site, provider:)

    described_class.for(provider:, site_type: :school)

    expect(provider.sites).not_to be_loaded
  end
end
