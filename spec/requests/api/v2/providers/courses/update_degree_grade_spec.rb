require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_degree_grade)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = updated_degree_grade

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
  let(:credentials)       { encode_to_credentials(payload) }

  let(:course)            {
    create :course,
           provider: provider,
           degree_grade: "two_one"
  }
  let(:permitted_params) do
    %i[degree_grade]
  end

  before do
    perform_request(updated_degree_grade)
  end

  context "course has an updated_degree_grade" do
    let(:updated_degree_grade) { { degree_grade: "two_two" } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the updated_degree_grade attribute to the correct value" do
      expect(course.reload.degree_grade).to eq(updated_degree_grade[:degree_grade])
    end
  end

  context "course has the same updated_degree_grade" do
    context "with values passed into the params" do
      let(:updated_degree_grade) { { degree_grade: "two_one" } }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change updated_degree_grade attribute" do
        expect(course.reload.degree_grade).to eq(updated_degree_grade[:degree_grade])
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_degree_grade) { {} }

    before do
      @degree_grade = course.degree_grade
      perform_request(updated_degree_grade)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change updated_degree_grade attribute" do
      expect(course.reload.degree_grade).to eq(@degree_grade)
    end
  end
end
