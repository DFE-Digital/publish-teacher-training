require "rails_helper"

describe 'PATCH /providers/:provider_code/courses/:course_code with sites' do
  let(:organisation) { create :organisation }
  let(:provider)     { create :provider, organisations: [organisation] }
  let(:user)         { create :user, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:course) { create :course, provider: provider }
  let(:site_to_add) { create :site, provider: provider }
  let(:unwanted_site) { create :site, provider: provider }
  let(:existing_site) { create :site, provider: provider }

  before do
    course.add_site!(site: existing_site)
    course.add_site!(site: unwanted_site)
  end

  let(:jsonapi_data) do
    {
      "_jsonapi" => {
        "data" => {
          "id" => course.id.to_s,
          "type" => "courses",
          "relationships" => {
            "sites" => {
              "data" => [
                { "type" => "sites", "id" => existing_site.id.to_s },
                { "type" => "sites", "id" => site_to_add.id.to_s }
              ]
            }
          }
        }
      }
    }
  end

  def perform_request
    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: jsonapi_data
  end

  context "course has some sites" do
    context "course is new" do
      before do
        perform_request
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "adds a new site" do
        expect(course.reload.sites.exists?(site_to_add.id)).to be(true)
      end

      it "leaves existing site in place" do
        expect(course.reload.sites.exists?(existing_site.id)).to be(true)
      end

      it "removes an unwanted site" do
        expect(course.reload.sites.exists?(unwanted_site.id)).to be(false)
      end
    end

    context "course is running" do
      before do
        course.publish_sites
        perform_request
      end

      it "suspends an unwanted site" do
        expect(
          course.reload.site_statuses.find_by(site_id: unwanted_site.id).status
        ).to eq("suspended")
      end
    end
  end
end
