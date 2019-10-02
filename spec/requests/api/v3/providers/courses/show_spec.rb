require "rails_helper"

describe "GET v3/providers/:provider_code/courses/:course_code" do
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:provider) { create :provider, recruitment_cycle: recruitment_cycle }
  let(:jsonapi_course) {
    JSON.parse(
      JSONAPI::Serializable::Renderer.new.render(
        course,
        class: {
          Course: API::V2::SerializableCourse,
        },
      ).to_json,
    )
  }
  let(:jsonapi_response) { JSON.parse(response.body) }
  let(:route) {
    "/api/v3/recruitment_cycles/#{recruitment_cycle.year}" \
    "/providers/#{provider.provider_code}" \
    "/courses/#{course.course_code}"
  }
  let(:course) { create :course, provider: provider, enrichments: enrichments }

  context "with a published course" do
    let(:enrichments) { [build(:course_enrichment, :published)] }

    it "returns full course information" do
      get route

      expect(jsonapi_response["data"]).to eq jsonapi_course["data"]
    end

    it "returns sparse course information" do
      requested_fields = %w[course_code name provider_code].sort
      get route + "?fields[courses]=#{requested_fields.join(',')}"

      expect(jsonapi_response["data"]["attributes"].keys).to eq requested_fields
    end
  end

  context "with a course with no enrichments" do
    let(:enrichments) { [] }

    it "returns nil course information" do
      get route

      expect(jsonapi_response["data"]).to eq nil
    end
  end

  context "with a course with a draft enrichment" do
    let(:enrichments) { [build(:course_enrichment, :initial_draft)] }

    it "returns nil course information" do
      get route

      expect(jsonapi_response["data"]).to eq nil
    end
  end

  def render_course(course)
    JSONAPI::Serializable::Renderer.new.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )
  end
end
