# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::AccreditedProviderSuggestionsController do
  describe '#index' do
    let!(:provider1) { create(:provider, :accredited_provider, provider_name: 'claydon provider') }
    let!(:provider2) { create(:provider, :accredited_provider, provider_name: 'claytown high provider') }
    let!(:provider3) { create(:provider, :accredited_provider, provider_name: 'another provider') }
    let!(:provider4) { create(:provider, provider_name: 'other provider') }

    context 'with invalid params' do
      before do
        get :index, params: {
          query: 'c'
        }
      end

      it 'responds with 400 status' do
        expect(json_response['errors']).to eq(
          [{ 'status' => 400, 'title' => 'BAD REQUEST', 'detail' => 'Unknown provider name, ukprn or postcode, please check the query string.' }]
        )
      end
    end

    context 'with valid params' do
      before do
        get :index, params: {
          query: 'cla'
        }
      end

      it 'responds with providers' do
        expect(json_response.keys).to match_array(%w[providers limit])

        expect(json_response['limit']).to be(15)
        expect(json_response['providers'][0]['id']).to eql(provider1.id)
        expect(json_response['providers'][0]['provider_name']).to eql(provider1.provider_name)
        expect(json_response['providers'][0]['provider_code']).to eql(provider1.provider_code)
        expect(json_response['providers'][1]['id']).to eql(provider2.id)
        expect(json_response['providers'][1]['provider_name']).to eql(provider2.provider_name)
        expect(json_response['providers'][1]['provider_code']).to eql(provider2.provider_code)
      end
    end
  end
end
