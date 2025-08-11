require "rails_helper"

RSpec.describe Publish::SchoolsChangedBannerComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(provider:))
    page
  end

  let(:recruitment_cycle) do
    create(:recruitment_cycle, year: 2026, application_start_date: 2.months.from_now)
  end
  let(:provider) { create(:provider, provider_code: "ABC", recruitment_cycle:) }

  context "when both added and removed schools" do
    before do
      create_list(:site, 2, provider:, added_via: :register_import)
      create_list(:site, 3, provider:, discarded_via_script: true)
    end

    it "shows both counts and both links" do
      expect(rendered).to have_text("We have added 2 schools")
      expect(rendered).to have_text("We have removed 3 schools")

      expect_to_have_link(text_snippet: "added", href_snippet: "added-schools")
      expect_to_have_link(text_snippet: "removed", href_snippet: "removed-schools")
    end
  end

  context "only added schools" do
    before { create(:site, provider: provider, added_via: :register_import) }

    it "shows added section and link, not removed" do
      expect(rendered).to have_text("We have added 1 school")
      expect(rendered).not_to have_text("We have removed")

      expect_to_have_link(text_snippet: "added", href_snippet: "added-schools")
      expect_not_to_have_link(text_snippet: "removed", href_snippet: "removed-schools")
    end
  end

  context "only removed schools" do
    before { create_list(:site, 2, provider: provider, discarded_via_script: true) }

    it "shows removed section and link, not added" do
      expect(rendered).to have_text("We have removed 2 schools")
      expect(rendered).not_to have_text("We have added")

      expect_to_have_link(text_snippet: "removed", href_snippet: "removed-schools")
      expect_not_to_have_link(text_snippet: "added", href_snippet: "added-schools")
    end
  end

  context "no added or removed schools" do
    it "shows the minimal banner only" do
      expect(rendered).to have_text("The way schools are added to your account has changed.")
      expect(rendered).not_to have_text("We have added")
      expect(rendered).not_to have_text("We have removed")

      expect_not_to_have_link(text_snippet: "added", href_snippet: "added-schools")
      expect_not_to_have_link(text_snippet: "removed", href_snippet: "removed-schools")
    end
  end

  context "not 2026 cycle" do
    let(:recruitment_cycle) { create(:recruitment_cycle, year: 2025, application_start_date: 1.month.from_now) }

    it "does not render the banner" do
      expect(render_inline(described_class.new(provider:)))
        .not_to have_css(".govuk-notification-banner")
    end
  end

  context "once the cycle has started" do
    let(:application_start_date) { 1.month.ago }
    let(:recruitment_cycle) { create(:recruitment_cycle, year: 2026, application_start_date:) }

    it "does not render the banner" do
      expect(render_inline(described_class.new(provider:)))
        .not_to have_css(".govuk-notification-banner")
    end
  end

private

  def banner_links
    return [] unless rendered.has_css?(".govuk-notification-banner")

    rendered.all(".govuk-notification-banner a")
  end

  def find_link_containing(text_snippet, href_snippet)
    banner_links.find do |link|
      link.text.include?(text_snippet) && link[:href].include?(href_snippet)
    end
  end

  def expect_to_have_link(text_snippet:, href_snippet:)
    link = find_link_containing(text_snippet, href_snippet)
    expect(link).to be_present,
                    "Expected to find link containing '#{text_snippet}' with href containing '#{href_snippet}'. " \
                    "Found links: #{banner_links.map { |l| "'#{l.text}' => #{l[:href]}" }.join(', ')}"
  end

  def expect_not_to_have_link(text_snippet:, href_snippet:)
    link = find_link_containing(text_snippet, href_snippet)
    expect(link).to be_nil,
                    "Expected NOT to find link containing '#{text_snippet}' with href containing '#{href_snippet}', " \
                    "but found: '#{link&.text}' => #{link&.[](:href)}"
  end
end
