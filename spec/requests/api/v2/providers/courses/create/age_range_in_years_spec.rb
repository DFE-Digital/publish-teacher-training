require "rails_helper"

RSpec.describe "POST /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:provider)          { create :provider, users: [user], recruitment_cycle: recruitment_cycle, sites: [site] }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:user)              { create :user }
  let(:payload)           { { email: user.email } }
  let(:credentials)       { encode_to_credentials(payload) }
  let(:course)            {
    build :course,
          provider: provider,
          age_range_in_years: age_range_in_years,
          subjects: subjects,
          sites: [site]
  }
  let(:site) { build(:site) }
  let(:subjects) { [find_or_create(:primary_subject)] }
  let(:age_range_in_years) { "3_to_7" }
  let(:json_data) { JSON.parse(response.body)["errors"] }

  before do
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourseWithoutName,
        PrimarySubject: API::V2::SerializableSubject,
        Site: API::V2::SerializableSite,
      },
      include: %i[subjects sites],
    )

    post "/api/v2/recruitment_cycles/#{recruitment_cycle.year}/providers/" \
         "#{course.provider.provider_code}/courses",
         headers: { "HTTP_AUTHORIZATION" => credentials },
         params: {
           _jsonapi: { data: jsonapi_data[:data] },
         }
  end

  context "with a valid age range" do
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "age_range_in_years attribute to the correct value" do
      expect(Course.first.age_range_in_years).to eq(age_range_in_years)
    end
  end

  context "when nil" do
    let(:age_range_in_years) { nil }

    it "returns an error" do
      expect(json_data.count).to eq 1
      expect(response.body).to include "Select an age range"
    end
  end

  context "an invalid age range" do
    context "with an age range of with a gap of less than 4 years" do
      let(:age_range_in_years) { "5_to_8" }
      let(:error_message) { "Age range must cover at least 4 years" }

      it "returns an error stating valid age ranges must be 4 years or greater" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_data.count).to eq 1
        expect(response.body).to include error_message
      end
    end

    context "with a from value that does not fall within the valid age range" do
      let(:age_range_in_years) { "1_to_15" }
      let(:error_message) { "Age range must be a school age" }

      it "returns an error stating valid age ranges must be 4 years or greater" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_data.count).to eq 1
        expect(response.body).to include error_message
      end
    end

    context "with a to value that does not fall within the valid age range" do
      let(:age_range_in_years) { "7_to_20" }
      let(:error_message) { "Age range must be a school age" }

      it "returns an error stating valid age ranges must be 4 years or greater" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_data.count).to eq 1
        expect(response.body).to include error_message
      end
    end

    context "with an age range that does not include a valid from age range value" do
      let(:age_range_in_years) { "to_6" }
      let(:error_message) { "Enter an age range" }

      it "returns an error stating that there is an invalid from year" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_data.count).to eq 1
        expect(response.body).to include error_message
      end
    end

    context "with an age range that does not include a valid to age range value" do
      let(:age_range_in_years) { "2_to" }
      let(:error_message) { "Enter an age range" }

      it "returns an error stating that there is an invalid from year" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_data.count).to eq 1
        expect(response.body).to include error_message
      end
    end
  end
end
