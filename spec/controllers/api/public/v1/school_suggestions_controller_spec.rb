# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::Public::V1::SchoolSuggestionsController do
  describe '#index' do
    let!(:site1) { create(:gias_school, name: 'claydon school') }
    let!(:site2) { create(:gias_school, name: 'claytown high school') }
    let!(:site3) { create(:gias_school, name: 'another school') }

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
