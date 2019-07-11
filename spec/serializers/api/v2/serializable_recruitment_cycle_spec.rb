require 'rails_helper'

describe API::V2::SerializableRecruitmentCycle do
  let(:recruitment_cycle) { create :recruitment_cycle }
  let(:resource) { described_class.new object: recruitment_cycle }

  it 'sets type to recruitment_cycles' do
    expect(resource.jsonapi_type).to eq :recruitment_cycles
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type 'recruitment_cycles' }
  it { should have_attribute(:year).with_value(recruitment_cycle.year) }
  it { should have_attribute(:application_start_date).with_value(recruitment_cycle.application_start_date.to_s) }
  it { should have_attribute(:application_end_date).with_value(recruitment_cycle.application_end_date.to_s) }
end
