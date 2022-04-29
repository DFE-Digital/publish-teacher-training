# frozen_string_literal: true

require "rails_helper"

module Header
  describe View do
    include Rails.application.routes.url_helpers

    alias_method :component, :page

    it "renders Service's name" do
      render_inline(described_class.new(service_name: "Test Service"))
      expect(component.find(".govuk-header__product-name")).to have_text("Test Service")
    end

    it "links to the homepage" do
      render_inline(described_class.new(service_name: "Test Service"))
      expect(page.has_link?(nil, href: publish_root_path)).to be true
    end

    it "doesn't contain a sign out link if no current user" do
      render_inline(described_class.new(service_name: "test"))
      expect(component).not_to have_text("Sign out")
    end

    context "for an admin user" do
      it "renders a sign out link" do
        render_inline(
          described_class.new(
            service_name: "test",
            current_user: build(:user, :admin),
          ),
        )

        expect(component).to have_text("Sign out")
      end
    end

    context "for a non-admin user" do
      it "links to the notifications section if associated_with_accredited_body" do
        user = build(:user)
        allow(user).to receive(:associated_with_accredited_body?).and_return true

        render_inline(described_class.new(service_name: "Test Service", current_user: user))

        expect(page.has_link?("Notifications", href: publish_notifications_path)).to be true
      end
    end
  end
end
