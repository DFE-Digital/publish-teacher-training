require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
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
  let(:provider)          { create :provider, users: [user] }
  let(:user)              { create :user }
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

  context "course has an updated_degree_grade" do
    let(:updated_degree_grade) { { degree_grade: "two_two" } }

    it "returns http success" do
      perform_request(updated_degree_grade)
      expect(response).to have_http_status(:success)
    end

    it "updates the updated_degree_grade attribute to the correct value" do
      expect {
        perform_request(updated_degree_grade)
      }.to change { course.reload.degree_grade }
             .from("two_one").to("two_two")
    end
  end

  context "course has the same updated_degree_grade" do
    context "with values passed into the params" do
      let(:updated_degree_grade) { { degree_grade: "two_one" } }

      it "returns http success" do
        perform_request(updated_degree_grade)
        expect(response).to have_http_status(:success)
      end

      it "does not change updated_degree_grade attribute" do
        expect {
          perform_request(updated_degree_grade)
        }.not_to change { course.reload.degree_grade }
             .from("two_one")
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_degree_grade) { {} }

    it "returns http success" do
      perform_request(updated_degree_grade)
      expect(response).to have_http_status(:success)
    end

    it "does not change updated_degree_grade attribute" do
      expect {
        perform_request(updated_degree_grade)
      }.not_to change { course.reload.degree_grade }
           .from("two_one")
    end
  end
end
