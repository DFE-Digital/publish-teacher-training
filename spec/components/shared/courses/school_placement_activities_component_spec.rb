# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::SchoolPlacementActivitiesComponent, type: :component do
  include Rails.application.routes.url_helpers

  context "fee paying course" do
    it "renders the correct content" do
      provider = build(:provider, selectable_school: false)
      course = build(
        :course,
        funding: "fee",
        provider:,
      ).decorate

      result = render_inline(described_class.new(course))

      expect(result).to have_css(".app-callout__title", text: "What to expect on school placements")
      expect(result).to have_css("p.govuk-body", text: "You will get hands-on experience of what it's like to be a teacher, and will have a dedicated mentor to support you throughout your training.")
      expect(result).to have_link(
        "Find out what to expect on school placements",
        href: I18n.t("find.get_into_teaching.url_type_of_course_provider"),
      )
    end
  end
end
