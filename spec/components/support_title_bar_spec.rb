# frozen_string_literal: true

require "rails_helper"

describe SupportTitleBar do
  alias_method :component, :page

  let(:current_user) { build(:user, :admin) }
  let(:current_year) { Find::CycleTimetable.current_year }

  def render_title_bar(path)
    with_request_url path, host: "publish.localhost" do
      render_inline(described_class.new(current_user:))
    end
  end

  context "when not during rollover", travel: mid_cycle(2025) do
    it "does not render the recruitment cycle" do
      render_title_bar "/support/#{current_year}/providers"

      expect(component).to have_no_text("Recruitment cycle")
      expect(component.has_link?("Change recruitment cycle", href: "/support")).to be false
    end
  end

  context "when next cycle is available for support users", travel: 1.hour.before(find_closes(2024)) do
    before do
      find_or_create(:recruitment_cycle, :next)
    end

    it "shows the current cycle dates on the providers list" do
      render_title_bar "/support/#{current_year}/providers"

      expect(component).to have_text("Recruitment cycle #{current_year - 1} to #{current_year} - current")
      expect(component).to have_link("Change recruitment cycle", href: "/support")
    end

    it "shows the selected cycle dates on a provider page" do
      render_title_bar "/support/#{current_year + 1}/providers"

      expect(component).to have_text("Recruitment cycle #{current_year} to #{current_year + 1}")
      expect(component).to have_no_text("- current")
    end

    it "shows the selected cycle dates on a page under providers" do
      render_title_bar "/support/#{current_year}/providers/1/courses"

      expect(component).to have_text("Recruitment cycle #{current_year - 1} to #{current_year} - current")
      expect(component).to have_link("Change recruitment cycle", href: "/support")
    end

    it "shows the current cycle dates on onboarding" do
      render_title_bar "/support/providers-onboarding-form-requests"

      expect(component).to have_text("Recruitment cycle #{current_year - 1} to #{current_year} - current")
      expect(component).to have_link("Change recruitment cycle", href: "/support")
    end

    %w[
      /support/candidates
      /support/candidates/1/details
      /support/feedback
      /support/subjects
      /support/financial-incentives
      /support/settings
      /support/feature-flags
      /support/recruitment_cycles
      /support/banners/active
    ].each do |path|
      it "does not show the recruitment cycle on #{path}" do
        render_title_bar path

        expect(component).to have_no_text("Recruitment cycle")
        expect(component.has_link?("Change recruitment cycle", href: "/support")).to be false
      end
    end

    it "does not show the recruitment cycle on users" do
      render_title_bar "/support/#{current_year}/users"

      expect(component).to have_no_text("Recruitment cycle")
      expect(component.has_link?("Change recruitment cycle", href: "/support")).to be false
    end

    it "does not show the recruitment cycle on a user's providers" do
      render_title_bar "/support/#{current_year}/users/1/providers"

      expect(component).to have_no_text("Recruitment cycle")
      expect(component.has_link?("Change recruitment cycle", href: "/support")).to be false
    end
  end
end
