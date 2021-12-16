# frozen_string_literal: true

require "rails_helper"

module Header
  describe View do
    alias_method :component, :page

    let(:items) { nil }

    before do
      render_inline(described_class.new(service_name: "Test Service", items: items))
    end

    it "renders Service's name" do
      expect(component.find(".govuk-header__product-name")).to have_text("Test Service")
    end

    it "does not render links" do
      expect(component).not_to have_selector(".app-header__content")
    end

    context "with one menu item" do
      let(:items) { [{ name: "Link", url: "www.google.com" }] }

      it "renders the link and adds the correct class" do
        expect(component.find_all(".app-header__content .govuk-header__link").length).to eq(1)
        expect(page).to have_css(".app-header__content--single-item")
      end
    end

    context "with multiple menu items" do
      let(:items) { [{ name: "Link1", url: "www.google.com" }, { name: "Link2", url: "www.google.com" }] }

      it "renders the links" do
        expect(component.find_all(".app-header__content .govuk-header__link").length).to eq(2)
        expect(page).not_to have_css(".app-header__content--single-item")
      end
    end
  end
end
