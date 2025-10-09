require "rails_helper"

describe "publish/authentication/sign_in/index.html.erb" do
  before { render }

  context "when find is closed", travel: 1.hour.before(find_opens) do
    it "rollover notification banner is displayed" do
      expect(rendered).to have_selector(".govuk-notification-banner", text: t("publish.rollover_notification.text"))
    end
  end

  context "when find is open", travel: 1.hour.after(find_opens) do
    it "rollover notification banner is not displayed" do
      expect(rendered).to have_no_selector(".govuk-notification-banner", text: t("publish.rollover_notification.text"))
    end
  end
end
