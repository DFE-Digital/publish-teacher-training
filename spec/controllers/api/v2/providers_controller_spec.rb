require "rails_helper"

RSpec.describe API::V2::ProvidersController do
  before :each do
    allow(controller).to receive(:authenticate).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#show_any" do
    context "when any provider uses endpoint" do
      let(:user) { provider.users.first }
      let(:provider) { create(:provider) }
      let(:course) { create(:course) }
      let(:other_provider) { course.provider }

      it "returns the specified provider" do
        get :show_any, params: {
          code: other_provider.provider_code,
          recruitment_cycle_year: other_provider.recruitment_cycle.year,
        }

        expect(JSON.parse(response.body).dig("data", "id").to_i).to eql(other_provider.id)
      end
    end
  end

  describe "#suggest_any" do
    context "when any provider uses endpoint" do
      let(:user) { provider.users.first }
      let!(:provider) { create(:provider) }
      let(:course) { create(:course) }
      let!(:other_provider) { course.provider }

      it "returns unassociated providers" do
        get :suggest_any, params: { query: other_provider.provider_code }
        expect(JSON.parse(response.body).dig("data").map { |p| p["id"] }).to eql([other_provider.id.to_s])
      end
    end

    context "with a filter" do
      let(:user) { provider.users.first }
      let!(:provider) { create(:provider) }
      let!(:in_scope_provider) { create(:provider, :accredited_body, provider_name: "in provider") }
      let!(:out_scope_provider) { create(:provider, provider_name: "out provider") }

      it "applies filter to results" do
        get :suggest_any, params: { query: "provider", filter: { only_accredited_body: "true" } }
        expect(JSON.parse(response.body).dig("data").map { |p| p["id"].to_i }).to eql([in_scope_provider.id])
      end

      it "applies filter to results" do
        get :suggest_any, params: { query: "provider", filter: { only_accredited_body: "false" } }
        expect(JSON.parse(response.body).dig("data").map { |p| p["id"].to_i }).to eql([in_scope_provider.id, out_scope_provider.id])
      end
    end
  end
end
