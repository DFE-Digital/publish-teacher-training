# frozen_string_literal: true

require 'rails_helper'

describe 'Provider authorization spec' do
  include DfESignInUserHelper

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:provider) { create(:provider, recruitment_cycle:, provider_code: 'A14') }
  let(:another_provider) { create(:provider) }
  let!(:user) { create(:user, providers: [provider]) }

  before { host! URI(Settings.base_url).host }

  describe 'GET /publish/organisations' do
    describe 'when authenticated user has one provider' do
      it 'redirects twice to the first valid providers courses' do
        get '/auth/dfe/callback', headers: { 'omniauth.auth' => user_exists_in_dfe_sign_in(user:) }
        get publish_root_path
        expect(response).to redirect_to('/publish/organisations/A14')
        follow_redirect!
        expect(response).to redirect_to('/publish/organisations/A14/2025/courses')
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'when authenticated user has two providers' do
      it 'renders the providers index' do
        user.providers << another_provider

        get '/auth/dfe/callback', headers: { 'omniauth.auth' => user_exists_in_dfe_sign_in(user:) }
        get publish_root_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /publish/organisations/:provider_code/:recruitment_cycle_year' do
    describe 'when the current_user is not authorized to see the provider code' do
      it 'returns 403' do
        get '/auth/dfe/callback', headers: { 'omniauth.auth' => user_exists_in_dfe_sign_in(user:) }
        get publish_provider_recruitment_cycle_courses_path(provider_code: another_provider.provider_code, recruitment_cycle_year: another_provider.recruitment_cycle.year)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
