# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Schools::PhaseFilterCalloutComponent, type: :component do
  let(:provider) { create(:provider) }

  it "explains that a primary course shows primary schools" do
    render_inline(described_class.new(provider:, level: "primary"))

    expect(page).to have_text("This is a primary course, so only primary schools are shown")
  end

  it "explains that a secondary course shows secondary schools" do
    render_inline(described_class.new(provider:, level: "secondary"))

    expect(page).to have_text("This is a secondary course, so only secondary schools are shown")
  end

  it "explains that a further education course shows further education schools" do
    render_inline(described_class.new(provider:, level: "further_education"))

    expect(page).to have_text(
      "This is a further education course, so only schools that offer further education are shown",
    )
  end

  it "tells the provider what they can do about a missing school" do
    render_inline(described_class.new(provider:, level: "primary"))

    expect(page).to have_text("If you cannot find a school you’re looking for, you can:")
  end

  it "links to the provider's own schools list" do
    render_inline(described_class.new(provider:, level: "primary"))

    expect(page).to have_link(
      "check that the school is in your account",
      href: "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/schools",
    )
  end

  it "links to GIAS" do
    render_inline(described_class.new(provider:, level: "primary"))

    expect(page).to have_link(
      "check the school’s details are correct on GIAS",
      href: I18n.t("publish.providers.schools.index.gias_url"),
    )
  end

  # The strict wording would be untrue: the picker deliberately keeps an
  # out-of-phase school that a rolled over course is already attached to.
  context "when the list contains an out-of-phase school" do
    it "softens the heading" do
      render_inline(described_class.new(provider:, level: "secondary", out_of_phase_schools: true))

      expect(page).to have_text(
        "This is a secondary course, so secondary schools are shown along with any school already attached to it",
      )
    end

    it "does not claim only secondary schools are shown" do
      render_inline(described_class.new(provider:, level: "secondary", out_of_phase_schools: true))

      expect(page).to have_no_text("only secondary schools are shown")
    end
  end

  context "when there is no level to filter on" do
    it "does not render" do
      render_inline(described_class.new(provider:, level: nil))

      expect(page).to have_no_css(".govuk-inset-text")
    end
  end
end
