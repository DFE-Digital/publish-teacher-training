require "rails_helper"

describe 'PATCH /providers/:provider_code/courses/:course_code' do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(course)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    )

    jsonapi_data.dig(:data, :attributes).slice!(*permitted_params)

    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: {
            _jsonapi: jsonapi_data
          }
  end
  let(:organisation)      { create :organisation }
  let(:provider)          { create :provider, organisations: [organisation], sites: [site] }
  let(:user)              { create :user, organisations: [organisation] }
  let(:payload)           { { email: user.email } }
  let(:token)             { build_jwt :apiv2, payload: payload }
  let(:course)            { create :course, provider: provider, site_statuses: [site_status], subjects: [primary_subject] }
  let(:site_status)       { build(:site_status, :findable, site: site) }
  let(:site)              { build(:site) }
  let(:primary_subject)   { build(:subject, subject_name: 'primary') }
  let(:updated_course)    {
    build :course,
          course_code: course.course_code,
            provider: provider,
            site_statuses: [site_status],
            subjects: [primary_subject],
            **gcse_requirements
  }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:permitted_params) do
    %i[english maths science]
  end

  context "course has updated gcse requirements" do
    let(:gcse_requirements) do
      {
        english: 2,
        maths: 2,
        science: 2
      }
    end

    before do
      updated_course.id = course.id
      perform_request(updated_course)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the english attribute to the correct value" do
      expect(course.reload.english).to eq(updated_course.english)
    end

    it "updates the maths attribute to the correct value" do
      expect(course.reload.maths).to eq(updated_course.maths)
    end

    it "updates the science attribute to the correct value" do
      expect(course.reload.science).to eq(updated_course.science)
    end
  end

  context "course has no updated gcse requirements" do
    context "with values passed into the params" do
      let(:gcse_requirements) do
        {
          english: 1,
          maths: 1,
          science: 1
        }
      end

      before do
        updated_course.id = course.id
        perform_request(updated_course)
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
        updated_course.id = course.id
        perform_request(updated_course)
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

      it "does not change science attribute" do
        expect(course.reload.science).to eq(course.science)
      end
    end
  end
end
