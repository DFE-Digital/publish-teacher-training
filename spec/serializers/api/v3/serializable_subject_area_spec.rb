# frozen_string_literal: true

require 'rails_helper'

describe API::V3::SerializableSubjectArea do
  subject { JSON.parse(resource.as_jsonapi.to_json) }

  let(:subject_area) { SubjectArea.first }
  let(:resource) { described_class.new(object: subject_area) }

  it 'sets type to subject_areas' do
    expect(resource.jsonapi_type).to eq(:subject_areas)
  end

  it { is_expected.to have_type 'subject_areas' }
  it { is_expected.to have_attribute(:typename).with_value(subject_area.typename) }
  it { is_expected.to have_attribute(:name).with_value(subject_area.name) }
end
