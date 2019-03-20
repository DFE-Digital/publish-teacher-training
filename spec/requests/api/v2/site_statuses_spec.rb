require 'rails_helper'

describe 'Site Helpers API V2' do
  let(:user) { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:payload) { { email: user.email } }
  let(:token) do
    JWT.encode payload,
                Settings.authentication.secret,
                Settings.authentication.algorithm
  end
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
  let!(:provider) { create(:provider, organisations: [organisation]) }

  describe 'PATCH update' do
    context 'when authenticated' do
      let(:course) do
        create(
          :course,
          provider: provider,
          with_site_statuses: %i[with_no_vacancies]
        )
      end
      let(:site_status) { course.site_statuses.first }
      let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
      let(:params) do
        {
          _jsonapi: jsonapi_renderer.render(
            site_status,
            class: {
              SiteStatus: API::V2::SerializableSiteStatus
            }
          )
        }
      end

      before do
        params[:_jsonapi][:data][:attributes][:vac_status] = 'full_time_vacancies'
      end

      subject do
        patch(
          api_v2_site_status_path(site_status),
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: params
        )
      end

      it 'updates vacancy status of site statuses for a course' do
        expect { subject }.to(change { site_status.reload.vac_status }
          .from('no_vacancies').to('full_time_vacancies'))
      end
    end
  end
end
