require "rails_helper"

describe "Site Helpers API V2" do
  let(:provider) { site_status.course.provider }
  let(:user) { create(:user).tap { |u| provider.users << u } }
  let(:payload) { { email: user.email } }
  let(:credentials) { encode_to_credentials(payload) }
  let(:site_status) { create :site_status }
  let(:params)      { {} }

  subject { response }

  def perform_request
    patch(
      api_v2_site_status_path(site_status),
      headers: { "HTTP_AUTHORIZATION" => credentials },
      params: params,
    )
  end

  describe "PATCH update" do
    context "when unauthenticated" do
      let(:payload) { { email: "foo@bar" } }

      before do
        perform_request
      end

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context "when unauthorised" do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }

      it "raises an error" do
        expect { perform_request }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context "when authorised" do
      let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
      let(:params) do
        {
          _jsonapi: jsonapi_renderer.render(
            site_status,
            class: {
              SiteStatus: API::V2::SerializableSiteStatus,
            },
          ),
        }
      end
      let(:site_status_params)         { params.dig :_jsonapi, :data, :attributes }
      let(:publish)                    { "published" }
      let(:status)                     { "discontinued" }
      let(:vac_status)                 { "no_vacancies" }
      let(:json_data)                  { JSON.parse(response.body)["data"] }

      before do
        site_status_params.merge!(
          publish: publish,
          status: status,
          vac_status: vac_status,
        )
      end

      subject { perform_request }

      it "updates publish on the site status" do
        expect { subject }.to(change { site_status.reload.publish }
          .from("unpublished").to(publish))
      end

      it "updates status on the site status" do
        expect { subject }.to(change { site_status.reload.status }
          .from("running").to(status))
      end

      it "updates vac_status on the site status" do
        expect { subject }.to(change { site_status.reload.vac_status }
          .from("full_time_vacancies").to(vac_status))
      end

      context "response output" do
        before do
          perform_request
        end

        subject { response }

        it { is_expected.to have_http_status(:success) }

        it "returns a JSON repsentation of the updated site site status" do
          subject

          expect(json_data).to have_id(site_status.id.to_s)
          expect(json_data).to have_type("site_statuses")
          expect(json_data).to have_jsonapi_attributes(
            :publish,
            :status,
            :vac_status,
          )
          expect(json_data).to have_relationship(:site)
        end
      end
    end
  end
end
