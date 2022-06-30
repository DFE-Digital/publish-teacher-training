require "rails_helper"

RSpec.describe API::Public::V1::Providers::Courses::LocationsController do
  let(:course) { create(:course) }
  let(:provider) { course.provider }

  describe "#index" do
    context "when a course does not have any locations" do
      before do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns empty array of data" do
        expect(json_response["data"]).to eql([])
      end
    end

    context "when a course has locations" do
      before do
        course.sites << build_list(:site, 2, provider:)

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns the correct number of locations" do
        expect(json_response["data"].size).to be(2)
      end

      context "with includes" do
        before do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            course_code: course.course_code,
            include: "recruitment_cycle,provider,course,location_status",
          }
        end

        it "returns the requested associated data in the response" do
          relationships = json_response["data"][0]["relationships"]

          recruitment_cycle_id = relationships.dig("recruitment_cycle", "data", "id").to_i
          provider_id = relationships.dig("provider", "data", "id").to_i
          course_id = relationships.dig("course", "data", "id").to_i
          location_status_id = relationships.dig("location_status", "data", "id").to_i

          expect(json_response["data"][0]["relationships"].keys.sort).to eq(
            %w[course location_status provider recruitment_cycle],
          )

          expect(recruitment_cycle_id).to eq(provider.recruitment_cycle.id)
          expect(provider_id).to eq(provider.id)
          expect(course_id).to eq(course.id)
          expect(location_status_id).to eq(course.site_statuses.first.id)
        end
      end
    end
  end
end
