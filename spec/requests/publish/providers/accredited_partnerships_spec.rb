# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish accredited partnerships", service: :publish do
  include DfESignInUserHelper

  let(:provider) { create(:provider, :lead_school) }
  let(:accredited_provider) { create(:provider, :accredited_provider) }
  let!(:partnership) { provider.accredited_partnerships.create!(accredited_provider:) }

  before { login_user(create(:user, :admin)) }

  describe "DELETE /publish/organisations/:provider_code/:recruitment_cycle_year/accredited-partnerships/:accredited_provider_code/delete" do
    def delete_partnership(**params)
      delete delete_publish_provider_recruitment_cycle_accredited_partnership_path(
        provider.provider_code,
        provider.recruitment_cycle_year,
        accredited_provider.provider_code,
        **params,
      )
    end

    context "when the accredited provider is not on any course" do
      it "shows the provider name as text in the Support success banner" do
        accredited_provider.update!(provider_name: %(Smith & Jones <b id="injected">University</b>))

        delete_partnership(return_to: "support")
        follow_redirect!

        banner = response.parsed_body.at_css(".govuk-notification-banner--success")
        expect(banner.text).to include(%(Smith & Jones <b id="injected">University</b>))
        expect(banner.at_css("#injected")).to be_nil
      end

      it "returns to the list when the partnership has already been removed" do
        delete_partnership(return_to: "support")
        delete_partnership(return_to: "support")

        expect(response).to redirect_to(
          support_recruitment_cycle_provider_accredited_partnerships_path(
            provider.recruitment_cycle_year,
            provider,
          ),
        )
      end

      it "shows the confirmation page again when the removal fails" do
        allow_any_instance_of(ProviderPartnership).to receive(:destroy).and_return(false) # rubocop:disable RSpec/AnyInstance

        delete_partnership(return_to: "support")

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Are you sure you want to remove this accredited provider?")
        expect(partnership.reload).to be_persisted
      end
    end

    context "when the accredited provider is on a course" do
      before { create(:course, provider:, accrediting_provider: accredited_provider) }

      it "keeps the partnership and redirects to the cannot remove page" do
        delete_partnership(return_to: "support")

        expect(partnership.reload).to be_persisted
        expect(response).to redirect_to(
          delete_publish_provider_recruitment_cycle_accredited_partnership_path(
            provider.provider_code,
            provider.recruitment_cycle_year,
            accredited_provider.provider_code,
            return_to: "support",
          ),
        )

        follow_redirect!

        expect(response.body).to include("You cannot remove this accredited provider")
      end
    end
  end
end
