require "rails_helper"

describe 'PATCH /providers/:provider_code/courses/:course_code' do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_start_date)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    )

    jsonapi_data[:data][:attributes] = updated_start_date

    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: {
            _jsonapi: jsonapi_data
          }
  end
  let(:organisation)      { create :organisation }
  let(:provider)          { build :provider, organisations: [organisation] }
  let(:user)              { create :user, organisations: [organisation] }
  let(:payload)           { { email: user.email } }
  let(:token)             { build_jwt :apiv2, payload: payload }

  let(:course)            {
    create :course,
           provider: provider,
           start_date: start_date
  }

  let(:start_date) { DateTime.new(provider.recruitment_cycle.year.to_i, 9, 1).utc }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:permitted_params) do
    %i[updated_start_date]
  end

  before do
    Timecop.freeze
    perform_request(updated_start_date)
  end

  after do
    Timecop.return
  end

  context "course has an updated start_date" do
    let(:timestamp_utc) { DateTime.new(course.provider.recruitment_cycle.year.to_i, 10, 1).utc }
    let(:updated_start_date) { { start_date: timestamp_utc.strftime("%B %Y") } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates start_date attribute to the correct value" do
      expect(course.reload.start_date.to_date).to eq(timestamp_utc)
    end
  end

  context "course has the same start_date" do
    context "with values passed into the params" do
      let(:timestamp_utc) { start_date }
      let(:updated_start_date) { { start_date: timestamp_utc.strftime("%B %Y") } }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change qualification attribute" do
        expect(course.reload.start_date).to eq(timestamp_utc)
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_start_date) { {} }
    let!(:course_start_date) { course.start_date }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change start_date attribute" do
      expect(course.reload.start_date).to eq(course_start_date)
    end
  end

  context 'for a course in the current cycle' do
    context 'with an invalid start date' do
      let(:next_cycles_year) { provider.recruitment_cycle.year.to_i + 1 }
      let(:updated_start_date) { { start_date: DateTime.new(next_cycles_year, 9, 1).strftime("%B %Y") } }
      let(:json_data) { JSON.parse(response.body)['errors'] }

      it "returns an error" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_data.count).to eq 1
        expect(response.body).to include("#{updated_start_date[:start_date]} is not in the #{provider.recruitment_cycle.year} cycle")
      end
    end
  end
end
