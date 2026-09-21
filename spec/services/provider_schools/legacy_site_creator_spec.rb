# frozen_string_literal: true

require "rails_helper"

describe ProviderSchools::LegacySiteCreator do
  let(:provider) { create(:provider) }
  let(:gias_school) { create(:gias_school) }
  let(:site) { provider.sites.build(gias_school.school_attributes) }

  it "persists the site" do
    expect {
      described_class.call(site:)
    }.to change(Site, :count).by(1)
  end

  it "returns the saved site" do
    result = described_class.call(site:)

    expect(result).to eq(site)
    expect(result).to be_persisted
  end

  it "raises when the site is invalid" do
    invalid_site = provider.sites.build

    expect {
      described_class.call(site: invalid_site)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  context "when GIAS holds no street for the school" do
    it "fills address line 1 from the first line it does hold" do
      gias_school = create(:gias_school, address1: "", address2: "Holbury", address3: "", town: "Southampton")

      site = described_class.call(site: provider.sites.build(gias_school.school_attributes))

      expect(site).to have_attributes(address1: "Holbury", address2: nil, town: "Southampton")
    end

    it "falls back to the town when that is the only line it holds" do
      gias_school = create(:gias_school, address1: "", address2: "", address3: "", town: "Southampton")

      site = described_class.call(site: provider.sites.build(gias_school.school_attributes))

      expect(site).to have_attributes(address1: "Southampton", town: nil)
    end

    it "raises when there is no line to fall back to" do
      gias_school = create(:gias_school, address1: "", address2: "", address3: "", town: "")

      expect {
        described_class.call(site: provider.sites.build(gias_school.school_attributes))
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
