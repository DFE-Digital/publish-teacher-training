# frozen_string_literal: true

require "rails_helper"

module TitleBar
  describe View do
    alias_method :component, :page
    let(:title) { "BAT School" }
    let(:provider_code) { "1BJ" }
    let(:current_user) { create(:user) }

    context "single org users" do
      before do
        render_inline(described_class.new(title:, current_user:, provider: provider_code))
      end

      it "does not render the provided title" do
        expect(component).not_to have_text("BAT School")
      end

      it "does not render the recruitment cycle link" do
        expect(component.has_link?("Change recruitment cycle", href: "/publish/organisations/1BJ")).to be false
      end
    end

    context "single org users during rollover" do
      before do
        allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(true)
        render_inline(described_class.new(title:, current_user:, provider: provider_code))
      end

      it "renders the provided title" do
        expect(component).to have_text("BAT School")
      end

      it "renders the recruitment cycle link" do
        expect(component.has_link?("Change recruitment cycle", href: "/publish/organisations/1BJ?switcher=true")).to be true
      end
    end
  end
end
