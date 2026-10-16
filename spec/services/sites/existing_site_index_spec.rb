# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sites::ExistingSiteIndex do
  let(:provider) { create(:provider) }

  describe "study sites" do
    subject(:index) { described_class.for(provider:) }

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

    described_class.for(provider:)

    expect(provider.sites).not_to be_loaded
  end
end
