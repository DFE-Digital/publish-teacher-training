require "rails_helper"

RSpec.describe API::Public::V1::SerializableRecruitmentCycle do
  let(:cycle) { create(:recruitment_cycle) }
  let(:resource) { described_class.new(object: cycle) }

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it "sets type to courses" do
    expect(resource.jsonapi_type).to eq(:recruitment_cycles)
  end

  it { is_expected.to have_type("recruitment_cycles") }

  it { is_expected.to have_attribute(:application_start_date).with_value(cycle.application_start_date.to_s) }
  it { is_expected.to have_attribute(:application_end_date).with_value(cycle.application_end_date.to_s) }
  it { is_expected.to have_attribute(:year).with_value(cycle.year.to_i) }
end
