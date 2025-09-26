# frozen_string_literal: true

require "rails_helper"

describe SupportTitleBar do
  alias_method :component, :page

  let(:current_user) { build(:user, :admin) }

  context "when not during rollover", travel: mid_cycle(2025) do
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

  context "when next cycle is available for support users", travel: 1.hour.before(find_closes(2024)) do
    before do
      find_or_create(:recruitment_cycle, :next)
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
