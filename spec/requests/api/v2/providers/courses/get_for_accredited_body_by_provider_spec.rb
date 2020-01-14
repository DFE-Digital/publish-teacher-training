require "rails_helper"

RSpec.describe "GET /api/v2/recruitment_cycles/:year/providers/\
  <provider_code>/training_providers/:training_provider_code/courses" do
  let(:organisation) { create(:organisation) }
  let(:user)         { create(:user, organisations: [organisation]) }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt(:apiv2, payload: payload) }
  let!(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:accredited_body) { create(:provider, :accredited_body, organisations: [organisation]) }
  let(:training_provider) { create(:provider) }

  let!(:course1) { create(:course, provider: training_provider, accrediting_provider: accredited_body) }
  let!(:course2) { create(:course, provider: training_provider) }

  def perform_request
    get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
  end

  let(:request_path) { "/api/v2/recruitment_cycles/#{recruitment_cycle.year}/providers/#{accredited_body.provider_code}/training_providers/#{training_provider.provider_code}/courses" }

  context "current recruitment cycle" do
    it "returns courses provided by the training provider that are\
    awarded by the awarding body with provider code <provider_code>" do
      perform_request

      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response.count).to eq(1)
      expect(parsed_response.first["id"]).to eq(course1.id.to_s)
    end
  end

  context "two recruitment cycle" do
    let(:next_recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }
    let(:next_training_provider) { create(:provider, :next_recruitment_cycle) }
    let(:next_course) { create(:course, provider: next_training_provider, accrediting_provider: accredited_body) }
    let(:request_path) { "/api/v2/recruitment_cycles/#{next_recruitment_cycle.year}/providers/#{next_accredited_body.provider_code}/training_providers/#{next_training_provider.provider_code}/courses" }
    let(:next_accredited_body) { create(:provider, :accredited_body, :next_recruitment_cycle, organisations: [organisation]) }

    before do
      next_course
    end

    it "only returns courses from the specified recruitment cycle" do
      perform_request

      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response.count).to eq(1)
      expect(parsed_response.first["id"]).to eq(next_course.id.to_s)
    end
  end
end
