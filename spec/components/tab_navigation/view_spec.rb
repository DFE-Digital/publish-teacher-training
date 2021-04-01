# frozen_string_literal: true

require "rails_helper"

module TabNavigation
  describe View do
    alias_method :component, :page

    let(:mock_link) { "https://www.gov.uk" }

    let(:items) do
      [
        { name: "Home", url: mock_link },
        { name: "Providers", url: mock_link },
      ]
    end

    context "default" do
      before do
        render_inline(described_class.new(items: items))
      end

      it "renders the provided links" do
        rendered_items = component.find_all(".app-tab-navigation__link")

        expect(rendered_items.size).to eq(2)
      end
    end

    context "with current item" do
      let(:active_item) { { name: "Training details", url: mock_link, current: true } }

      before do
        render_inline(described_class.new(items: items.prepend(active_item)))
      end

      it "renders the current item with the correct class" do
        rendered_link = component.find(".app-tab-navigation__link", text: active_item[:name])
        expect(rendered_link["aria-current"]).to eq("page")
      end
    end
  end
end
