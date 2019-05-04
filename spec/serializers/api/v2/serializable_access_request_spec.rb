require "rails_helper"

describe API::V2::SerializableAccessRequest do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  let(:access_request) { create(:access_request) }
  let(:access_request_json) do
    jsonapi_renderer.render(
      access_request,
      class: {
        AccessRequest: API::V2::SerializableAccessRequest
      }
    ).to_json
  end
  let(:parsed_json) { JSON.parse(access_request_json) }

  subject { parsed_json['data'] }

  it { should have_type('access_request') }

  it {
    should have_attributes(:email_address, :first_name, :last_name, :organisation,
                           :request_date_utc, :requester_id, :status, :requester_email)
  }

  context 'with a requester' do
    let(:requester) { User.find_by!(id: access_request.requester_id) }
    let(:access_request_json) do
      jsonapi_renderer.render(
        access_request,
        class: {
          AccessRequest: API::V2::SerializableAccessRequest,
          User: API::V2::SerializableUser
        },
        include: [
          :requester
        ]
      ).to_json
    end

    it { should have_relationship(:requester) }

    it 'includes the provider' do
      expect(parsed_json['included'])
        .to(include(have_type('users')
          .and(have_id(requester.id.to_s))))
    end
  end
  describe "has the correct attributes" do
    it { expect(subject["attributes"]).to include("email_address" => access_request.email_address) }
    it { expect(subject["attributes"]).to include("first_name" => access_request.first_name) }
    it { expect(subject["attributes"]).to include("last_name" => access_request.last_name) }
    it { expect(subject["attributes"]).to include("organisation" => access_request.organisation) }
    it { expect(subject["attributes"]).to include("reason" => access_request.reason) }
    it { expect(subject["attributes"]).to include("request_date_utc" => access_request.request_date_utc.iso8601) }
    it { expect(subject["attributes"]).to include("requester_id" => access_request.requester_id) }
    it { expect(subject["attributes"]).to include("status" => access_request.status) }
    it { expect(subject["attributes"]).to include("requester_email" => access_request.requester_email) }
  end
end
