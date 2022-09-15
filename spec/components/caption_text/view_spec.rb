# frozen_string_literal: true

require "rails_helper"

module CaptionText
  describe View do
    alias_method :component, :page

    before do
      render_inline(described_class.new(text: "Enter some random text here"))
    end

    it "renders all the correct details" do
      expect(page).to have_css "span[class='govuk-caption-l']", text: "Enter some random text here"
    end
  end
end
