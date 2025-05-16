# frozen_string_literal: true

require "rails_helper"

describe TitleBar do
  alias_method :component, :page
  let(:title) { "BAT School" }
  let(:provider_code) { "1BJ" }
  let(:current_user) { create(:user) }

  context "single org users" do
    before do
      create(:recruitment_cycle, :next, available_in_publish_from: 1.day.from_now)
      render_inline(described_class.new(title:, current_user:, provider: provider_code))
    end

    it "does not render the provided title" do
      expect(component).to have_no_text("BAT School")
    end

    it "does not render the recruitment cycle link" do
      expect(component.has_link?("Change recruitment cycle", href: "/publish/organisations/1BJ")).to be false
    end
  end

  context "single org users during rollover" do
    before do
      create(:recruitment_cycle, :next, available_in_publish_from: 1.day.ago)
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
