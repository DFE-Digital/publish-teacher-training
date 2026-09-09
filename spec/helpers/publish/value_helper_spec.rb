# frozen_string_literal: true

require "rails_helper"

module Publish
  describe ValueHelper do
    include GovukVisuallyHiddenHelper
    include GovukComponentsHelper
    include GovukLinkHelper

    describe "#value_provided?" do
      it "returns a default text when value is nil" do
        expect(value_provided?(nil)).to eq('<span class="govuk-hint">Not entered</span>')
      end

      it "returns a default text when value is empty" do
        expect(value_provided?("")).to eq('<span class="govuk-hint">Not entered</span>')
      end
    end

    describe "#value_prompt" do
      it "renders a blue-bordered inset link to the page that fills the field in" do
        html = Capybara.string(value_prompt("Enter course length", "/publish/length"))

        expect(html).to have_css(".govuk-inset-text.app-inset-text--narrow-border.app-inset-text--important")
        expect(html).to have_link("Enter course length", href: "/publish/length")
      end
    end

    describe "#value_none" do
      it "reads the same as a course with no placement schools" do
        expect(value_none).to eq('<span class="app-!-colour-muted">None</span>')
      end
    end
  end
end
