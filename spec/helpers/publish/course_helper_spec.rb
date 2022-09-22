# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseHelper, type: :helper do
    describe "#course_value_provided?" do
      it "returns a default text when value is nil" do
        expect(course_value_provided?(nil)).to eq("<span class=\"govuk-hint\">Not entered</span>")
      end

      it "returns a default text when value is empty" do
        expect(course_value_provided?("")).to eq("<span class=\"govuk-hint\">Not entered</span>")
      end
    end
  end
end
