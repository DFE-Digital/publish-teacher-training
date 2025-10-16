# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::WhatIsAnAccreditedProviderComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:provider) { build(:provider, provider_code: "ABC", selectable_school: false) }

  context "when the course has a different accredited provider" do
    let(:course) { build(:course, provider:, accredited_provider_code: "XYZ").decorate }

    it "renders the correct title and content" do
      result = render_inline(described_class.new(course: course))

      expect(result).to have_css(".app-callout__title", text: "What is an accredited provider?")
      expect(result).to have_css(
        "p.govuk-body",
        text: "Accredited providers are organisations approved by the government to manage teacher training and recommend candidates for qualified teacher status (QTS). They oversee the quality of the training, while training providers focus on delivering it.",
      )
    end
  end

  context "when the course is self-accredited" do
    let(:course) { build(:course, provider:, accredited_provider_code: nil).decorate }

    it "does not render the callout box" do
      result = render_inline(described_class.new(course: course))
      expect(result).not_to have_css(".app-callout__title")
    end
  end

  context "when the accredited provider is the same as the training provider" do
    let(:course) { build(:course, provider:, accredited_provider_code: "ABC").decorate }

    it "does not render the callout box" do
      result = render_inline(described_class.new(course: course))
      expect(result).not_to have_css(".app-callout__title")
    end
  end
end
