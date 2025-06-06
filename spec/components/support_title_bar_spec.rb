# frozen_string_literal: true

require "rails_helper"

describe SupportTitleBar do
  alias_method :component, :page

  context "not during rollover" do
    before do
      render_inline(described_class.new)
    end

    it "does not render the provided title" do
      expect(component).to have_no_text("Recruitment cycle #{Settings.current_recruitment_cycle_year}")
    end

    it "does not render the recruitment cycle link" do
      expect(component.has_link?("Change recruitment cycle", href: "/support")).to be false
    end
  end

  context "during rollover" do
    before do
      allow(RecruitmentCycle).to receive(:next_editable_cycles?).and_return(true)
      render_inline(described_class.new)
    end

    it "renders the provided title" do
      expect(component).to have_text("Recruitment cycle #{Settings.current_recruitment_cycle_year}")
    end

    it "renders the recruitment cycle link" do
      expect(component.has_link?("Change recruitment cycle", href: "/support")).to be true
    end
  end
end
