# frozen_string_literal: true

require "rails_helper"

module Persona
  describe View do
    alias_method :component, :page

    before do
      render_inline(described_class.new(email_address: "becomingateacher+admin-integration-tests@digital.education.gov.uk",
        first_name: "Support agent", last_name: "Colin"))
    end

    it "renders a govuk button" do
      expect(component).to have_selector(".govuk-button")
    end

    it "renders personas last name in the button text" do
      expect(component).to have_button("Login as Colin")
    end

    it "redirects to the developer auth" do
      expect(component.find("form")["action"]).to eq("/auth/developer/callback")
    end
  end
end
