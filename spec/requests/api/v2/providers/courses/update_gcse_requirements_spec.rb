require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:provider)          { create :provider, users: [user] }
  let(:user)              { create :user }
  let(:payload)           { { email: user.email } }
  let(:credentials)       { encode_to_credentials(payload) }
  let(:course)            {
    create :course,
           provider: provider,
           subjects: [find_or_create(:primary_subject, :primary)]
  }
  let(:permitted_params) do
    %i[english maths science]
  end

  def perform_request(gcse_requirements)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = gcse_requirements

    patch "/api/v2/providers/#{course.provider.provider_code}" \
          "/courses/#{course.course_code}",
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: {
            _jsonapi: jsonapi_data,
          }
  end

  before do
    perform_request(gcse_requirements)
  end

  context "course has updated gcse requirements" do
    let(:gcse_requirements) do
      {
        english: "expect_to_achieve_before_training_begins",
        maths: "expect_to_achieve_before_training_begins",
        science: "expect_to_achieve_before_training_begins",
      }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the english attribute to the correct value" do
      expect(course.reload.english).to eq(gcse_requirements[:english])
    end

    it "updates the maths attribute to the correct value" do
      expect(course.reload.maths).to eq(gcse_requirements[:maths])
    end

    it "updates the science attribute to the correct value" do
      expect(course.reload.science).to eq(gcse_requirements[:science])
    end
  end

  context "course has no updated gcse requirements" do
    context "with values passed into the params" do
      let(:gcse_requirements) do
        {
          english: "must_have_qualification_at_application_time",
          maths: "must_have_qualification_at_application_time",
          science: "must_have_qualification_at_application_time",
        }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change english attribute" do
        expect(course.reload.english).to eq(course.english)
      end

      it "does not change maths attribute" do
        expect(course.reload.maths).to eq(course.maths)
      end

      it "does not change the science attribute" do
        expect(course.reload.science).to eq(course.science)
      end
    end

    context "with no values passed into the params" do
      let(:gcse_requirements) { {} }

      before do
        @english = course.english
        @maths = course.maths
        @science = course.science
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change english attribute" do
        expect(course.reload.english).to eq(@english)
      end

      it "does not change maths attribute" do
        expect(course.reload.maths).to eq(@maths)
      end

      it "does not change science attribute" do
        expect(course.reload.science).to eq(@science)
      end
    end
  end

  context "when not_set is provided on a primary course" do
    let(:json_data) { JSON.parse(response.body)["errors"] }
    let(:gcse_requirements) { { english: "not_set", maths: "not_set", science: "not_set" } }

    it "returns 200 ok" do
      expect(response).to have_http_status(:ok)
    end
  end

  context "when not_set is provided on a secondary course" do
    let(:secondary_subject) { find_or_create(:secondary_subject) }
    let(:json_data) { JSON.parse(response.body)["errors"] }
    let(:gcse_requirements) { { english: "not_set", maths: "not_set", science: "not_set" } }

    let(:course) {
      create :course,
             provider: provider,
             level: "secondary",
             subjects: [secondary_subject]
    }

    it "returns 200 ok" do
      expect(response).to have_http_status(:ok)
    end

    it "does not change any attribute" do
      expect(course.reload.maths).to eq("not_set")
      expect(course.reload.english).to eq("not_set")
      expect(course.reload.science).to eq("not_set")
    end
  end

  context "when unknown values are provided on a course" do
    let(:json_data) { JSON.parse(response.body)["errors"] }
    let(:gcse_requirements) { { english: "must_have_qualification_at_application_time", maths: nil, science: "blah" } }

    it "returns an error" do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "has validation errors" do
      expect(json_data.count).to eq 1
      expect(response.body).to include("Science is invalid")
    end
  end
end
