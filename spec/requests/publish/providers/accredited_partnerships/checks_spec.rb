# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish provider accredited partnerships check", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:accredited_provider) { create(:provider, :accredited_provider, provider_name: "UCL") }

  before { login_user(user) }

  def add_accredited_provider
    put check_publish_provider_recruitment_cycle_accredited_partnerships_path(
      provider.provider_code,
      recruitment_cycle.year,
      accredited_provider_id: accredited_provider.id,
    )
  end

  describe "PUT /publish/organisations/:provider_code/:recruitment_cycle_year/accredited-partnerships/check" do
    it "adds the accredited partnership and redirects to the publish index" do
      expect { add_accredited_provider }
        .to change { provider.accredited_partnerships.count }.by(1)

      expect(response).to redirect_to(
        publish_provider_recruitment_cycle_accredited_partnerships_path(
          provider.provider_code,
          recruitment_cycle.year,
        ),
      )
      expect(flash[:success_with_body]).to eq(
        { "title" => "Accredited provider added", "body" => "UCL" },
      )
    end

    context "when returning to support" do
      let(:user) { create(:user, :admin) }
      let(:provider) { create(:provider, :lead_school) }

      before { login_user(user) }

      def add_accredited_provider
        put check_publish_provider_recruitment_cycle_accredited_partnerships_path(
          provider.provider_code,
          recruitment_cycle.year,
          accredited_provider_id: accredited_provider.id,
          return_to: "support",
        )
      end

      it "redirects to the support accredited partnerships list with a success flash" do
        expect { add_accredited_provider }
          .to change { provider.accredited_partnerships.count }.by(1)

        expect(response).to redirect_to(
          support_recruitment_cycle_provider_accredited_partnerships_path(
            recruitment_cycle.year,
            provider,
          ),
        )
        expect(flash[:success_with_body]).to eq(
          { "title" => "Accredited provider added", "body" => "UCL" },
        )
      end
    end
  end
end
