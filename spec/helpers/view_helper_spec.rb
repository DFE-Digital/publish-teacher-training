require "rails_helper"

feature "View helpers", type: :helper do
  describe "#govuk_link_to" do
    it "returns an anchor tag with the govuk-link class" do
      expect(helper.govuk_link_to("ACME SCITT", "https://localhost:44364/organisations/A0")).to eq("<a class=\"govuk-link\" href=\"https://localhost:44364/organisations/A0\">ACME SCITT</a>")
    end
  end

  describe "#govuk_back_link_to" do
    it "returns an anchor tag with the govuk-back-link class" do
      expect(helper.govuk_back_link_to("https://localhost:44364/organisations/A0")).to eq("<a class=\"govuk-back-link\" data-qa=\"page-back\" href=\"https://localhost:44364/organisations/A0\">Back</a>")
    end
  end

  describe "#bat_contact_email_address" do
    it "returns bat_contact_email_address" do
      expect(helper.bat_contact_email_address).to eq(Settings.service_support.contact_email_address)
    end
  end

  describe "#bat_contact_email_address_with_wrap" do
    it "returns bat_contact_email_address_with_wrap" do
      expect(helper.bat_contact_email_address_with_wrap).to eq(Settings.service_support.contact_email_address.gsub("@", "<wbr>@"))
    end
  end

  describe "#bat_contact_mail_to" do
    it "returns bat_contact_mail_to" do
      expect(helper.bat_contact_mail_to).to eq(
        "<a class=\"govuk-link\" href=\"mailto:#{Settings.service_support.contact_email_address}\">#{Settings.service_support.contact_email_address}</a>",
        )
    end
  end

  describe "#header_environment_class" do
    it "returns header_environment_class" do
      expect(helper.header_environment_class).to eq("app-header__container--#{Settings.environment.selector_name}")
    end
  end

  describe "#beta_tag_environment_class" do
    it "returns beta_tag_environment_class" do
      expect(helper.beta_tag_environment_class).to eq("app-tag--#{Settings.environment.selector_name}")
    end
  end

  describe "#beta_banner_environment_label" do
    it "returns beta_banner_environment_label" do
      expect(helper.beta_banner_environment_label).to eq(Settings.environment.label)
    end
  end
end
