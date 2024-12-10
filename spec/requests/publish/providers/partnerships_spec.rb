# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Publish::Providers::Partnerships' do
  include DfESignInUserHelper

  let(:year) { find_or_create(:recruitment_cycle).year }
  let(:accredited_provider) { create(:accredited_provider) }
  let(:training_provider) { create(:provider) }
  let(:partnership) { create(:provider_partnership, training_provider:, accredited_provider:) }

  before { login_user(user) }

  describe 'when the user is of the accredited provider' do
    let(:user) { create(:user, providers: [accredited_provider]) }

    describe 'GET /' do
      it 'returns http success' do
        get "/publish/organisations/#{accredited_provider.provider_code}/#{year}/partnerships"
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /show' do
      it 'returns http success' do
        get "/publish/organisations/#{partnership.accredited_provider.provider_code}/#{year}/partnerships/#{partnership.training_provider.provider_code}"
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /new' do
      it 'returns http success' do
        get "/publish/organisations/#{partnership.accredited_provider.provider_code}/#{year}/partnerships/new"
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /create' do
      it 'returns http success' do
        post "/publish/organisations/#{partnership.accredited_provider.provider_code}/#{year}/partnerships"
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'GET /edit' do
      it 'returns http success' do
        get "/publish/organisations/#{partnership.accredited_provider.provider_code}/#{year}/partnerships/#{partnership.training_provider.provider_code}/edit"
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /update' do
      it 'returns http success' do
        patch "/publish/organisations/#{accredited_provider.provider_code}/#{year}/partnerships/#{partnership.training_provider.provider_code}"
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'GET /destroy' do
      it 'returns http success' do
        delete "/publish/organisations/#{partnership.accredited_provider.provider_code}/#{year}/partnerships/#{partnership.training_provider.provider_code}"
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'when the user is of the training provider' do
    let(:user) { create(:user, providers: [training_provider]) }

    describe 'GET /' do
      it 'returns http success' do
        get "/publish/organisations/#{training_provider.provider_code}/#{year}/partnerships"
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /show' do
      it 'returns http success' do
        get "/publish/organisations/#{partnership.training_provider.provider_code}/#{year}/partnerships/#{partnership.accredited_provider.provider_code}"
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /new' do
      it 'returns http success' do
        get "/publish/organisations/#{partnership.training_provider.provider_code}/#{year}/partnerships/new"
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /create' do
      it 'returns http success' do
        post "/publish/organisations/#{partnership.training_provider.provider_code}/#{year}/partnerships"
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'GET /edit' do
      it 'returns http success' do
        get "/publish/organisations/#{partnership.training_provider.provider_code}/#{year}/partnerships/#{partnership.accredited_provider.provider_code}/edit"
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /update' do
      it 'returns http success' do
        patch "/publish/organisations/#{training_provider.provider_code}/#{year}/partnerships/#{partnership.accredited_provider.provider_code}"
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'GET /destroy' do
      it 'returns http success' do
        delete "/publish/organisations/#{partnership.training_provider.provider_code}/#{year}/partnerships/#{partnership.accredited_provider.provider_code}"
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
