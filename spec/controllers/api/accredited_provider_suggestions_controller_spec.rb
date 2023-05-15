# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::AccreditedProviderSuggestionsController do
  describe '#index' do
    let!(:ap1) { create(:provider, :accredited_provider, provider_name: 'claydon') }
    let!(:ap2) { create(:provider, :accredited_provider, provider_name: 'claytown') }
    let!(:ap3) { create(:provider, :accredited_provider, provider_name: 'another') }

    context 'with invalid params' do
      before do
        get :index, params: {
          query: 'cl'
        }
      end

      it 'responds with 400 status' do
        binding.pry
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

      it 'responds with a suggestion list' do
        expect(json_response.size).to eq 2
        expect(json_response[0]['id']).to eql(ap1.id)
        expect(json_response[0]['provider_name']).to eql(ap1.provider_name)
        expect(json_response[1]['id']).to eql(ap2.id)
        expect(json_response[1]['provider_name']).to eql(ap2.provider_name)
      end
    end
  end
end
