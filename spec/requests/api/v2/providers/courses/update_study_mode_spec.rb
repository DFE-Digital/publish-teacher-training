require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:provider)          { create :provider, users: [user], sites: [site] }
  let(:user)              { create :user }
  let(:payload)           { { email: user.email } }
  let(:credentials)       { encode_to_credentials(payload) }
  let(:course)            {
    create :course,
           provider: provider,
           study_mode: study_mode,
           site_statuses: [site_status1, site_status2, site_status3, site_status4]
  }
  let(:site_status1) { build(:site_status, :findable, :part_time_vacancies, site: site) }
  let(:site_status2) { build(:site_status, :findable, :full_time_vacancies, site: site) }
  let(:site_status3) { build(:site_status, :findable, :both_full_time_and_part_time_vacancies, site: site) }
  let(:site_status4) { build(:site_status, :findable, :with_no_vacancies, site: site) }
  let(:site) { build(:site) }
  let(:study_mode) { :full_time_or_part_time }
  let(:permitted_params) do
    %i[study_mode]
  end

  def perform_request(updated_study_mode)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = updated_study_mode

    patch "/api/v2/providers/#{course.provider.provider_code}" \
          "/courses/#{course.course_code}",
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: {
            _jsonapi: jsonapi_data,
          }
  end

  before do
    perform_request(updated_study_mode)
  end

  context "when a course is updated to full time" do
    let(:updated_study_mode) { { study_mode: :full_time } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the study_mode attribute to the correct value" do
      expect(course.reload.study_mode).to eq(updated_study_mode[:study_mode].to_s)
    end

    it "updates all site_statuses vac_status to full_time_vacancies except no_vacancies" do
      expect(site_status1.reload.vac_status).to eq("full_time_vacancies")
      expect(site_status2.reload.vac_status).to eq("full_time_vacancies")
      expect(site_status3.reload.vac_status).to eq("full_time_vacancies")
      expect(site_status4.reload.vac_status).to eq("no_vacancies")
    end
  end

  context "when a course is updated to part time" do
    let(:updated_study_mode) { { study_mode: :part_time } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the study_mode attribute to the correct value" do
      expect(course.reload.study_mode).to eq(updated_study_mode[:study_mode].to_s)
    end

    it "updates all site_statuses vac_status to part_time_vacancies except no_vacancies" do
      expect(site_status1.reload.vac_status).to eq("part_time_vacancies")
      expect(site_status2.reload.vac_status).to eq("part_time_vacancies")
      expect(site_status3.reload.vac_status).to eq("part_time_vacancies")
      expect(site_status4.reload.vac_status).to eq("no_vacancies")
    end
  end

  context "with no values passed into the params" do
    let!(:courses_study_mode) { course.study_mode }
    let(:updated_study_mode) { {} }

    before do
      perform_request(updated_study_mode)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change study_mode attribute" do
      expect(course.reload.study_mode).to eq(courses_study_mode)
    end
  end
end
