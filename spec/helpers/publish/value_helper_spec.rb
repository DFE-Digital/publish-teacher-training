# frozen_string_literal: true

require "rails_helper"

module Publish
  describe ValueHelper do
    describe "#value_provided?" do
      it "returns a default text when value is nil" do
        expect(value_provided?(nil)).to eq('<span class="govuk-hint">Not entered</span>')
      end

      it "returns a default text when value is empty" do
        expect(value_provided?("")).to eq('<span class="govuk-hint">Not entered</span>')
      end
    end

    describe "#value_none" do
      it "reads the same as a course with no placement schools" do
        expect(value_none).to eq('<span class="app-!-colour-muted">None</span>')
      end
    end
  end
end
