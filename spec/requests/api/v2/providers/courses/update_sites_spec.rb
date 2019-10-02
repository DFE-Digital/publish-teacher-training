require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code with sites" do
  let(:organisation) { create :organisation }
  let(:provider)     { create :provider, organisations: [organisation] }
  let(:user)         { create :user, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:course) { create :course, provider: provider, site_statuses: [site_status], subjects: [primary_subject], enrichments: [course_enrichment] }
  let(:course_enrichment) { build :course_enrichment }
  let(:site_status) { build(:site_status) }
  let(:primary_subject) { build(:subject, :primary) }
  let(:site_to_add) { create :site, provider: provider }
  let(:unwanted_site) { create :site, provider: provider }
  let(:existing_site) { create :site, provider: provider }

  before do
    course.add_site!(site: existing_site)
    course.add_site!(site: unwanted_site)
  end

  let(:sites_payload) {
    [
      { "type" => "sites", "id" => existing_site.id.to_s },
      { "type" => "sites", "id" => site_to_add.id.to_s },
    ]
  }

  let(:jsonapi_data) do
    {
      "_jsonapi" => {
        "data" => {
          "id" => course.id.to_s,
          "type" => "courses",
          "relationships" => {
            "sites" => {
              "data" => sites_payload,
            },
          },
        },
      },
    }
  end

  let!(:sync_courses_request_stub) do
    stub_request(:put, %r{#{Settings.search_api.base_url}/api/courses/})
      .to_return(
        status: 200,
        body: '{ "result": true }',
      )
  end

  def perform_request
    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: {
            "HTTP_AUTHORIZATION" => credentials,
            'Content-Type': "application/json",
          },
          params: jsonapi_data.to_json
  end

  context "course has some sites" do
    context "course is new" do
      before do
        perform_enqueued_jobs do
          perform_request
        end
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

      it "does not sync the course" do
        expect(sync_courses_request_stub).not_to have_been_requested
      end
    end

    context "course is running" do
      let(:course_enrichment) { build :course_enrichment, :published }

      before do
        course.publish_sites
        perform_enqueued_jobs do
          perform_request
        end
      end

      it "syncs the course" do
        expect(course.is_published?).to be(true)
        expect(sync_courses_request_stub).to have_been_requested
      end

      it "suspends an unwanted site" do
        expect(
          course.reload.site_statuses.find_by(site_id: unwanted_site.id).status,
        ).to eq("suspended")
      end
    end

    context "removing all sites" do
      let(:sites_payload) { [] }

      before do
        perform_enqueued_jobs do
          perform_request
        end
      end

      it "returns http 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "leaves existing site in place" do
        expect(course.reload.sites.exists?(existing_site.id)).to be(true)
        expect(course.reload.sites.exists?(unwanted_site.id)).to be(true)
      end

      it "returns validation error" do
        expect(response.body).to include("You must choose at least one location")
      end

      it "doesn't sync the course" do
        expect(sync_courses_request_stub).to_not have_been_requested
      end
    end
  end
end
