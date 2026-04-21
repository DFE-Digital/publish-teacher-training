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
end
