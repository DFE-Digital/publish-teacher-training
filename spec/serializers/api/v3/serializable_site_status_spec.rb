# frozen_string_literal: true

require 'rails_helper'

describe API::V3::SerializableSiteStatus do
  subject { JSON.parse(resource.as_jsonapi.to_json) }

  let(:site_status) { create(:site_status) }
  let(:resource) { described_class.new object: site_status }

  it 'sets type to site_statuses' do
    expect(resource.jsonapi_type).to eq :site_statuses
  end

  it { is_expected.to have_type 'site_statuses' }
end
