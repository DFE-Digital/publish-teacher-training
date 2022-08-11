# frozen_string_literal: true

require "rails_helper"

module FindInterface::Header
  describe View do
    include Rails.application.routes.url_helpers

    alias_method :component, :page

    it "renders Service's name" do
      render_inline(described_class.new(service_name: "Test Service"))
      expect(component.find(".govuk-header__product-name")).to have_text("Test Service")
    end

    it "links to the homepage" do
      render_inline(described_class.new(service_name: "Test Service"))
      expect(page.has_link?(nil, href: find_path)).to be true
    end
  end
end
