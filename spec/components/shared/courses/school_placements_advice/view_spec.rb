# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::SchoolPlacementsAdvice::View, type: :component do
  include Rails.application.routes.url_helpers

  context "salaried course" do
    it "renders the correct content" do
      provider = build(:provider, selectable_school: false)
      course = build(
        :course,
        funding: "salary",
        provider:,
      ).decorate

      result = render_inline(described_class.new(course))

      expect(result).to have_css(".app-callout__title", text: "Where your school placements will take place")
      expect(result).to have_css("p.govuk-body", text: "The training provider will contact you to discuss your preferences, to help them select placement schools you can travel to.")
      expect(result).to have_link(
        "Find out more about where your school placements will take place",
        href: I18n.t("find.get_into_teaching.url_school_placements"),
      )
    end
  end
end
