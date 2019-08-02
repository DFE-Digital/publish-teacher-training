describe 'PATCH /providers/:provider_code/courses/:course_code' do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(subjects)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    )

    jsonapi_data[:data][:attributes] = subjects

    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: {
            _jsonapi: jsonapi_data
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
           subjects: [english, secondary]
  }
  let(:secondary) { create(:subject, :secondary) }
  let(:english) { create(:subject, :english) }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:permitted_params) do
    %i[subjects]
  end

  before do
    perform_request(subjects)
  end

  context "course has an updated subject" do
    let(:mathematics) { create(:subject, :mathematics) }
    let(:subjects) do
      {
        subjects: [mathematics, secondary]
      }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates subjects to the correct value" do
      expect(course.reload.subjects).to eq(subjects[:subjects])
    end
  end

  context "course has not updated its subjects" do
    context "with values passed into the params" do
      let(:subjects) do
        {
          subjects: [english, secondary]
        }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change the subjects" do
        expect(course.reload.subjects).to eq(subjects[:subjects])
      end
    end
    context "with no values passed into the params" do
      let(:subjects) { {} }

      before do
        @subjects = course.subjects
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change english attribute" do
        expect(course.reload.subjects).to eq(@subjects)
      end
    end
  end
end
