# frozen_string_literal: true

require "rails_helper"

describe UtmHelper do
  let(:params) do
    { utm_source: "email", utm_medium: "email", utm_campaign: "weekly_digest" }
  end

  describe "#with_utm" do
    it "appends utm params to a url without an existing query string" do
      result = helper.with_utm("https://example.com/page", params:, content: "course_link")

      expect(result).to eq(
        "https://example.com/page?utm_campaign=weekly_digest&utm_content=course_link&utm_medium=email&utm_source=email",
      )
    end

    it "preserves an existing query string" do
      result = helper.with_utm("https://example.com/results?order=newest_course", params:, content: "view_more_courses")

      expect(result).to start_with("https://example.com/results?order=newest_course&")
      expect(result).to include("utm_content=view_more_courses")
    end
  end
end
