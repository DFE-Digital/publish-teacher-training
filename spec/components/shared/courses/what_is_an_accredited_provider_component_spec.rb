# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::WhatIsAnAccreditedProviderComponent, type: :component do
  include Rails.application.routes.url_helpers

  context "accredited provider description callout box displays correctly" do
    let(:provider) { build(:provider, selectable_school: false) }
    let(:course) { build(:course, funding: "fee", provider:).decorate }

    it "renders the correct title and content" do
      result = render_inline(described_class.new(course: course))

      expect(result).to have_css(".app-callout__title", text: "What is an accredited provider?")
      expect(result).to have_css("p.govuk-body", text: "Accredited providers are organisations approved by the government to manage teacher training and recommend candidates for qualified teacher status (QTS). They oversee the quality of the training, while training providers focus on delivering it.")
    end
  end
end
