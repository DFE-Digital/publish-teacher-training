# frozen_string_literal: true

require "rails_helper"

module TitleBar
  describe View do
    alias_method :component, :page
    let(:title) { "BAT School" }

    context "default" do
      before do
        render_inline(described_class.new(title: title))
      end

      it "renders the provided title" do
        expect(component).to have_text("BAT School")
      end

      it "renders the provided link" do
        expect(component).to have_link("Change organisation", href: "/")
      end
    end
  end
end
