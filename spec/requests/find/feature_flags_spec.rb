# frozen_string_literal: true

require 'rails_helper'

module Find
  describe '/feature-flags' do
    before do
      host! 'www.find-example.com'
    end

    it 'responds with unauthorized without basic auth' do
      get '/feature-flags'

      expect(response).to have_http_status(:unauthorized)
    end

    it 'responds with 200 without basic auth' do
      get '/feature-flags', headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'password') }

      expect(response).to have_http_status(:ok)
    end
  end
end
