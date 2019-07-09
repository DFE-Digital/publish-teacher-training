require "rails_helper"

describe '/api/v2/recruitment_cycle', type: :request do
  describe '/api/v2/recruitment_cycle/%<year>' do
    let(:user) { create(:user, organisations: [organisation]) }
    let(:organisation) { create(:organisation) }
    let(:payload) { { email: user.email } }
    let(:token) do
      JWT.encode payload,
                 Settings.authentication.secret,
                 Settings.authentication.algorithm
    end
    let(:credentials) do
      ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:request_params) { {} }
    let(:request_path) { "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" }

    def perform_request
      get request_path,
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: request_params
    end

    let(:expected_response) {
      {
        'data' => {
          'id' => recruitment_cycle.id.to_s,
          'type' => 'recruitment_cycles',
          'attributes' => {
            'year' => recruitment_cycle.year,
            'application_start_date' => recruitment_cycle.application_start_date.to_s,
            'application_end_date' =>   recruitment_cycle.application_end_date.to_date.to_s,
          },
          'relationships' => {
            'providers' => {
              'meta' => {
                'included' => false
              }
            },
          }
        },
        'jsonapi' => {
          'version' => '1.0'
        }
      }
    }
    let(:json_response) { JSON.parse(response.body) }

    describe 'the JSON response' do
      it 'should be the correct jsonapi response' do
        perform_request

        expect(json_response).to eq expected_response
      end
    end
  end
end
