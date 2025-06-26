# frozen_string_literal: true

require "rails_helper"

describe SupportTitleBar do
  alias_method :component, :page

  let(:current_user) { build(:user, :admin) }

  context "when not during rollover" do
    before do
      render_inline(described_class.new(current_user:))
    end

    it "does not render the provided title" do
      expect(component).to have_no_text("Recruitment cycle #{RecruitmentCycle.current.year}")
    end

    it "does not render the recruitment cycle link" do
      expect(component.has_link?("Change recruitment cycle", href: "/support")).to be false
    end
  end

  context "when next cycle is available for support users" do
    before do
      create(:recruitment_cycle, :next, available_for_support_users_from: 1.day.ago)
      render_inline(described_class.new(current_user:))
    end

    it "renders the provided title" do
      expect(component).to have_text("Recruitment cycle #{RecruitmentCycle.current.year}")
    end

    it "renders the recruitment cycle link" do
      expect(component).to have_text("Change recruitment cycle")
      expect(component.has_link?("Change recruitment cycle", href: "/support")).to be true
    end
  end
end
