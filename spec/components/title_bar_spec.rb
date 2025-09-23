# frozen_string_literal: true

require "rails_helper"

describe TitleBar do
  alias_method :component, :page
  let(:title) { "BAT School" }
  let(:provider_code) { "1BJ" }
  let(:current_user) { create(:user) }

  context "single org users" do
    before do
      allow(RecruitmentCycle).to receive(:upcoming_cycles_open_to_publish?).and_return(false)
      render_inline(described_class.new(title:, current_user:, provider: provider_code))
    end

    it "does not render the provided title" do
      expect(component).to have_no_text("BAT School")
    end

    it "does not render the recruitment cycle link" do
      expect(component.has_link?("Change recruitment cycle", href: "/publish/organisations/1BJ")).to be false
    end
  end

  context "single org users during rollover", travel: 1.day.before(find_closes) do
    subject { described_class.new(title:, current_user:, provider: provider_code) }

    before do
      find_or_create(:recruitment_cycle, :next)
    end

    context "when viewing the current cycle" do
      it "renders the provided title" do
        # stub recruitment_cycle_year - hard to test params outside controller
        allow(subject).to receive(:recruitment_cycle_year).and_return(Find::CycleTimetable.current_year) # rubocop:disable RSpec/SubjectStub
        render_inline(subject)
        expect(component).to have_text("BAT School")
        expect(component).to have_text("- #{RecruitmentCycle.current_recruitment_cycle.year_range} - current")
      end
    end

    context "when viewing the next cycle" do
      it "renders the provided title" do
        # stub recruitment_cycle_year - hard to test params outside controller
        allow(subject).to receive(:recruitment_cycle_year).and_return(Find::CycleTimetable.next_year) # rubocop:disable RSpec/SubjectStub
        render_inline(subject)
        expect(component).to have_text("BAT School")
        expect(component).to have_text("- #{RecruitmentCycle.current_recruitment_cycle.next.year_range}")
      end
    end

    it "renders the recruitment cycle link" do
      render_inline(subject)
      expect(component.has_link?("Change recruitment cycle", href: "/publish/organisations/1BJ?switcher=true")).to be true
    end
  end
end
