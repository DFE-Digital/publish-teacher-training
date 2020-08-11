require "rails_helper"

RSpec.describe API::Public::V1::Providers::LocationsController do
  let(:course) { create(:course) }
  let(:provider) { course.provider }

  describe "#index" do
    context "when a course does not have any locations" do
      it "returns empty array of data" do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
        expect(JSON.parse(response.body)["data"]).to eql([])
      end
    end

    context "when a course has locations" do
      before do
        course.sites << build_list(:site, 2)
      end

      it "returns the correct number of locations" do
        get :index, params: {
          recruitment_cycle_year: "2020",
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }

        expect(JSON.parse(response.body)["data"].size).to eql(2)
      end
    end
  end
end
