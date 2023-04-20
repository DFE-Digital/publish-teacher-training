# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::Public::V1::SchoolSuggestionsController do
  describe '#index' do
    let!(:site1) { create(:gias_school, name: 'claydon school') }
    let!(:site2) { create(:gias_school, name: 'claytown high school') }
    let!(:site3) { create(:gias_school, name: 'another school') }

    context 'with invalid params' do
      before do
        get :index, params: {
          query: 'cl'
        }
      end

      it 'responds with 400 status' do
        expect(json_response['errors']).to eq(
          [{ 'status' => 400, 'title' => 'BAD REQUEST', 'detail' => 'Unknown school name, urn or postcode, please check the query string.' }]
        )
      end
    end

    context 'with valid params' do
      before do
        get :index, params: {
          query: 'cla'
        }
      end

      it 'responds with a SchoolSuggestionListResponse' do
        expect(json_response[0]['id']).to eql(site1.id)
        expect(json_response[0]['name']).to eql(site1.name)
        expect(json_response[1]['id']).to eql(site2.id)
        expect(json_response[1]['name']).to eql(site2.name)
      end
    end
  end
end
