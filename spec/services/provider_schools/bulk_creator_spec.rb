# frozen_string_literal: true

require "rails_helper"

describe ProviderSchools::BulkCreator do
  let(:provider) { create(:provider) }

  it "reports the school it could not save to Sentry" do
    unsaveable = create(:gias_school, address1: "", address2: "", address3: "", town: "", postcode: "")

    allow(Sentry).to receive(:capture_exception)

    described_class.call(provider:, gias_schools: [unsaveable])

    expect(Sentry).to have_received(:capture_exception).with(an_instance_of(ActiveRecord::RecordInvalid))
  end

  it "writes a legacy site alongside each provider school by default" do
    gias_school = create(:gias_school)

    expect {
      described_class.call(provider:, gias_schools: [gias_school])
    }.to change { provider.sites.count }.by(1)
      .and change { provider.schools.count }.by(1)
  end

  context "without the legacy site" do
    it "creates only the provider school" do
      gias_school = create(:gias_school)

      expect {
        result = described_class.call(provider:, gias_schools: [gias_school], legacy_site: false)
        expect(result.saved).to contain_exactly(have_attributes(gias_school_id: gias_school.id))
      }.to change { provider.schools.count }.by(1)
        .and(not_change { provider.sites.count })
    end

    it "leaves a school with an incomplete address unsaved" do
      incomplete = create(:gias_school, address1: "", address2: "", address3: "", town: "", postcode: "")

      expect {
        result = described_class.call(provider:, gias_schools: [incomplete], legacy_site: false)
        expect(result.unsaved).to contain_exactly(incomplete)
      }.not_to(change { provider.schools.count })
    end
  end
end
