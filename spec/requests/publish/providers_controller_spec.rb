# frozen_string_literal: true

require 'rails_helper'

describe 'Publish::ProvidersController' do
  include DfESignInUserHelper

  let(:user) { create(:user, :with_provider) }

  describe '/publish/providers/suggest' do
    context 'when the user is authenticated' do
      it 'is successful' do
        login_user(user)
        get '/publish/providers/suggest'
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the user is not authenticated' do
      it 'is successful' do
        get '/publish/providers/suggest'
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
