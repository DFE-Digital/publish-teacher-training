require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code with sites" do
  let(:provider)     { create :provider }
  let(:user)         { create :user, providers: [provider] }
  let(:payload)      { { email: user.email } }
  let(:credentials) { encode_to_credentials(payload) }

  let(:course) { create(:course, :infer_level, provider: provider, site_statuses: [site_status], subjects: [primary_subject], enrichments: [course_enrichment]) }
  let(:course_enrichment) { build :course_enrichment }
  let(:site_status) { build(:site_status) }
  let(:primary_subject) { find_or_create(:primary_subject, :primary_with_mathematics) }
  let(:site_to_add) { create :site, provider: provider }
  let(:unwanted_site) { create :site, provider: provider }
  let(:existing_site) { create :site, provider: provider }

  before do
    course.sites = [site_status.site, existing_site, unwanted_site]
  end

  def perform_request
    patch "/api/v2/providers/#{course.provider.provider_code}" \
          "/courses/#{course.course_code}",
          headers: {
            "HTTP_AUTHORIZATION" => credentials,
            "Content-Type": "application/json",
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
    end

    context "course is running" do
      let(:course_enrichment) { build :course_enrichment, :published }

      before do
        course.publish_sites
        perform_enqueued_jobs do
          perform_request
        end
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
        expect(response.body).to include("Select at least one location")
      end
    end
  end
end
