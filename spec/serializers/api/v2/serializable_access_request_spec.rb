require "rails_helper"

describe API::V2::SerializableAccessRequest do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  let(:access_request) { create(:access_request) }
  let(:access_request_json) do
    jsonapi_renderer.render(
      access_request,
      class: {
        AccessRequest: API::V2::SerializableAccessRequest,
      },
    ).to_json
  end
  let(:parsed_json) { JSON.parse(access_request_json) }

  subject { parsed_json["data"] }

  it { is_expected.to have_type("access_request") }

  it {
    expect(subject).to have_jsonapi_attributes(:email_address,
                                               :first_name,
                                               :last_name,
                                               :organisation,
                                               :request_date_utc,
                                               :requester_id,
                                               :status,
                                               :requester_email)
  }

  context "with a requester" do
    let(:requester) { User.find_by!(id: access_request.requester_id) }
    let(:access_request_json) do
      jsonapi_renderer.render(
        access_request,
        class: {
          AccessRequest: API::V2::SerializableAccessRequest,
          User: API::V2::SerializableUser,
        },
        include: [
          :requester,
        ],
      ).to_json
    end

    it { is_expected.to have_relationship(:requester) }

    it "includes the provider" do
      expect(parsed_json["included"])
        .to(include(have_type("users")
          .and(have_id(requester.id.to_s))))
    end
  end

  describe "has the correct attributes" do
    it { is_expected.to have_attribute(:email_address).with_value(access_request.email_address) }
    it { is_expected.to have_attribute(:first_name).with_value(access_request.first_name) }
    it { is_expected.to have_attribute(:last_name).with_value(access_request.last_name) }
    it { is_expected.to have_attribute(:organisation).with_value(access_request.organisation) }
    it { is_expected.to have_attribute(:reason).with_value(access_request.reason) }
    it { is_expected.to have_attribute(:request_date_utc).with_value(access_request.request_date_utc.iso8601) }
    it { is_expected.to have_attribute(:requester_id).with_value(access_request.requester_id) }
    it { is_expected.to have_attribute(:status).with_value(access_request.status) }
    it { is_expected.to have_attribute(:requester_email).with_value(access_request.requester_email) }
  end
end
