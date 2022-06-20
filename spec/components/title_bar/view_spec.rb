# frozen_string_literal: true

require "rails_helper"

module TitleBar
  describe View do
    alias_method :component, :page
    let(:title) { "BAT School" }
    let(:provider_code) { "1BJ" }

    context "default" do
      before do
        render_inline(described_class.new(title: title, provider: provider_code))
      end

      it "renders the provided title" do
        expect(component).to have_text("BAT School")
      end

      it "renders the change organisation link" do
        expect(component).to have_link("Change organisation", href: "/")
      end

      it "renders the recruitment cycle link" do
        expect(component).to have_link("Change recruitment cycle", href: "/publish/organisations/1BJ")
      end
    end
  end
end
