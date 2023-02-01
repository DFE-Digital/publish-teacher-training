# frozen_string_literal: true

require 'spec_helper_smoke'

describe 'V1 Public API Smoke Tests', :aggregate_failures, smoke: true do
  subject(:response) { HTTParty.get(url) }

  let(:recruitment_year) { Settings.current_recruitment_cycle_year }
  let(:base_url) { Settings.publish_api_url }

  context 'providers' do
    describe 'GET /v1/recruitment_cycles/:recruitment_year/providers' do
      let(:url) { "#{base_url}/api/public/v1/recruitment_cycles/#{recruitment_year}/providers?[per_page]=1" }

      it 'returns a HTTP status code of 200' do
        expect(response.code).to eq(200)
      end

      it 'returns at least one record' do
        expect(response.parsed_response['data'].length).to be_positive
      end
    end
  end
end
