require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_qualification)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = updated_qualification

    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: {
            _jsonapi: jsonapi_data,
          }
  end
  let(:organisation)      { create :organisation }
  let(:provider)          { create :provider, organisations: [organisation] }
  let(:user)              { create :user, organisations: [organisation] }
  let(:payload)           { { email: user.email } }
  let(:token)             { build_jwt :apiv2, payload: payload }

  let(:course)            {
    create :course,
           provider: provider,
           ucas_subjects: [subject],
           qualification: qualification
  }
  let(:qualification) { :pgce_with_qts }
  let(:subject) { build(:ucas_subject, :primary) }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:permitted_params) do
    %i[updated_qualification]
  end

  before do
    perform_request(updated_qualification)
  end

  context "course has an updated qualification" do
    let(:updated_qualification) { { qualification: "pgde_with_qts" } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the qualification attribute to the correct value" do
      expect(course.reload.qualification).to eq(updated_qualification[:qualification])
    end
  end

  context "course has the same qualification" do
    context "with values passed into the params" do
      let(:updated_qualification) { { qualification: "pgce_with_qts" } }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change qualification attribute" do
        expect(course.reload.qualification).to eq(updated_qualification[:qualification])
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_qualification) { {} }

    before do
      @qualification = course.qualification
      perform_request(updated_qualification)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change qualification attribute" do
      expect(course.reload.qualification).to eq(@qualification)
    end
  end

  context "when course level is further education" do
    context "with an invalid qualification" do
      let(:json_data) { JSON.parse(response.body)["errors"] }
      let(:updated_qualification) { { qualification: "pgce_with_qts" } }
      let(:subject) { build(:further_education_subject) }
      let(:qualification) { :pgce }

      it "returns an error" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_data.count).to eq 1
        expect(response.body).to include("PGCE with QTS is not valid for a further education course")
      end
    end
  end

  context "for any course" do
    context "when a bad qualification is submitted" do
      let(:json_data) { JSON.parse(response.body)["errors"] }
      let(:updated_qualification) { { qualification: "blah_blah" } }

      it "returns an error" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_data.count).to eq 1
        expect(response.body).to include("Invalid qualification")
      end
    end
  end

  context "when course level is not further education" do
    context "with an invalid qualification" do
      let(:json_data) { JSON.parse(response.body)["errors"] }
      let(:updated_qualification) { { qualification: "pgce" } }
      let(:qualification) { :pgce_with_qts }

      it "returns an error" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_data.count).to eq 1
        expect(response.body).to include("PGCE is not valid for a primary course")
      end
    end
  end
end
