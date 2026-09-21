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
end
