# frozen_string_literal: true

require "rails_helper"

module NavigationBar
  describe View do
    alias_method :component, :page

    let(:item_url) { "https://www.gov.uk" }
    let(:current_path) { item_url }
    let(:current_user) { build(:user) }

    before do
      render_inline(described_class.new(items: items, current_path: current_path, current_user: current_user {}))
    end

    context "where item current is true" do
      let(:current_item) { { name: "Bulk actions", url: item_url, current: true } }
      let(:current_path) { "http://www.google.com" }
      let(:items) { [current_item] }

      it "renders the link with aria-current" do
        rendered_link = component.find(".moj-primary-navigation__link", text: current_item[:name])
        expect(rendered_link["aria-current"]).to eq("page")
      end
    end

    context "where item current is false" do
      let(:non_current_item) { { name: "Trainee records", url: item_url, current: false } }
      let(:items) { [non_current_item] }

      context "when not on the current url" do
        let(:current_path) { "http://www.google.com" }

        it "renders the link without aria-current" do
          rendered_link = component.find(".moj-primary-navigation__link", text: non_current_item[:name])
          expect(rendered_link["aria-current"]).to eq(nil)
        end
      end

      context "when on the current url" do
        it "renders the link with aria-current" do
          rendered_link = component.find(".moj-primary-navigation__link", text: non_current_item[:name])
          expect(rendered_link["aria-current"]).to eq("page")
        end
      end
    end

    context "where item current is not set" do
      let(:no_current_item) { { name: "Trainee records", url: item_url } }
      let(:items) { [no_current_item] }

      context "when not on the current url" do
        let(:current_path) { "http://www.google.com" }

        it "renders the link without aria-current" do
          rendered_link = component.find(".moj-primary-navigation__link", text: no_current_item[:name])
          expect(rendered_link["aria-current"]).to eq(nil)
        end
      end

      context "when on the current url" do
        it "renders the link with aria-current" do
          rendered_link = component.find(".moj-primary-navigation__link", text: no_current_item[:name])
          expect(rendered_link["aria-current"]).to eq("page")
        end
      end
    end
  end
end
