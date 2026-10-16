# frozen_string_literal: true

require "rails_helper"

describe ProviderSchools::BulkCreator do
  let(:provider) { create(:provider) }

  it "creates only the provider school" do
    gias_school = create(:gias_school)

    expect {
      result = described_class.call(provider:, gias_schools: [gias_school])
      expect(result.saved).to contain_exactly(have_attributes(gias_school_id: gias_school.id))
    }.to change { provider.schools.count }.by(1)
      .and(not_change { provider.sites.count })
  end

  it "leaves a school with an incomplete address unsaved" do
    incomplete = create(:gias_school, address1: "", address2: "", address3: "", town: "", postcode: "")

    expect {
      result = described_class.call(provider:, gias_schools: [incomplete])
      expect(result.unsaved).to contain_exactly(incomplete)
    }.not_to(change { provider.schools.count })
  end

  it "reports a school it could not save to Sentry and carries on" do
    failing, saveable = create_list(:gias_school, 2)
    allow(ProviderSchools::Creator).to receive(:call).and_call_original
    allow(ProviderSchools::Creator).to receive(:call).with(provider:, gias_school_id: failing.id)
      .and_raise(ActiveRecord::RecordInvalid)
    allow(Sentry).to receive(:capture_exception)

    result = described_class.call(provider:, gias_schools: [failing, saveable])

    expect(result.unsaved).to contain_exactly(failing)
    expect(result.saved).to contain_exactly(have_attributes(gias_school_id: saveable.id))
    expect(Sentry).to have_received(:capture_exception).with(an_instance_of(ActiveRecord::RecordInvalid))
  end
end
