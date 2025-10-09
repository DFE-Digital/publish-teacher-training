require "rails_helper"

describe "Rollover banner spec" do
  include DfESignInUserHelper

  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }

  before { login_user(user) }

  describe "/courses" do
    context "when find is closed", travel: 1.hour.before(find_opens) do
      it "shows the rollover notifiation banner" do
        get "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/courses"

        expect(response.body).to include(I18n.t("publish.rollover_notification.text"))
      end
    end

    context "when find is open", travel: 1.hour.after(find_opens) do
      it "does not show the rollover notifiation banner" do
        get "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/courses"

        expect(response.body).not_to include(I18n.t("publish.rollover_notification.text"))
      end
    end
  end
end
