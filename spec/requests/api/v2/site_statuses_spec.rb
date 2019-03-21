require 'rails_helper'

describe 'Site Helpers API V2' do
  let(:user) { create(:user).tap { |u| organisation.users << u } }
  let(:organisation) { site_status.course.provider.organisations.first }
  let(:payload) { { email: user.email } }
  let(:token) do
    JWT.encode payload,
                Settings.authentication.secret,
                Settings.authentication.algorithm
  end
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
  let(:site_status) { create :site_status }
  let(:params)      { {} }
  let(:perform_request) do
    patch(
      api_v2_site_status_path(site_status),
      headers: { 'HTTP_AUTHORIZATION' => credentials },
      params: params
    )
  end

  subject { response }

  describe 'PATCH update' do
    context 'when unauthenticated' do
      let(:payload) { { email: 'foo@bar' } }

      before do
        perform_request
      end

      it { should have_http_status(:unauthorized) }
    end

    context 'when unauthorised' do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }

      it 'raises an error' do
        expect { perform_request }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context 'when authorised' do
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
      let(:site_status_params)         { params.dig :_jsonapi, :data, :attributes }
      let(:applications_accepted_from) { '2019-01-01 00:00:00' }
      let(:publish)                    { 'published' }
      let(:status)                     { 'discontinued' }
      let(:vac_status)                 { 'no_vacancies' }
      let(:json_data)                  { JSON.parse(response.body)['data'] }

      before do
        site_status_params.merge!(
          applications_accepted_from: applications_accepted_from,
          publish:                    publish,
          status:                     status,
          vac_status:                 vac_status,
        )
      end

      subject { perform_request }

      it 'updates applications_accepted_from on the site status' do
        expect { subject }.to(
          change { site_status.reload.applications_accepted_from }
          .to(Date.parse(applications_accepted_from))
        )
      end

      it 'updates publish on the site status' do
        expect { subject }.to(change { site_status.reload.publish }
          .from('unpublished').to(publish))
      end

      it 'updates status on the site status' do
        expect { subject }.to(change { site_status.reload.status }
          .from('running').to(status))
      end

      it 'updates vac_status on the site status' do
        expect { subject }.to(change { site_status.reload.vac_status }
          .from('full_time_vacancies').to(vac_status))
      end

      context 'response output' do
        before do
          perform_request
        end

        subject { response }

        it { should have_http_status(:success) }

        it 'returns a JSON repsentation of the updated site site status' do
          subject

          expect(json_data).to have_id(site_status.id.to_s)
          expect(json_data).to have_type('site_statuses')
          expect(json_data).to have_attributes(
            :applications_accepted_from,
            :publish,
            :status,
            :vac_status
          )
          expect(json_data).to have_relationship(:site)
        end
      end
    end
  end
end
