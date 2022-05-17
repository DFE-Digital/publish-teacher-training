require "rails_helper"

RSpec.describe API::V2::AccreditedProviderTrainingProvidersController do
  let(:current_user) do
    create(:user, admin: true, email: "admin@digital.education.gov.uk")
  end

  let(:provider) { course.accrediting_provider }
  let(:training_provider) { course.provider }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:course) { create(:course, :with_accrediting_provider) }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe "#show" do
    it "returns the training provider" do
      get :show, params: {
        recruitment_cycle_year: recruitment_cycle.year,
        provider_code: provider.provider_code,
        training_provider_code: training_provider.provider_code,
      }

      expect(JSON.parse(response.body).dig("data", "id").to_i).to eql(training_provider.id)
    end
  end
end
