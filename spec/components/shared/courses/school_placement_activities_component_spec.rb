# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::SchoolPlacementActivitiesComponent, type: :component do
  include Rails.application.routes.url_helpers

  context "the school placement activities callout box displays correctly" do
    let(:provider) { build(:provider, selectable_school: false) }
    let(:course)   { build(:course, funding: "fee", provider:).decorate }

    it "renders the correct title and content" do
      result = render_inline(described_class.new(course: course, is_preview: false))

      expect(result).to have_css(".app-callout__title", text: "What to expect on school placements")
      expect(result).to have_css("p.govuk-body", text: "You will get hands-on experience of what it's like to be a teacher, and will have a dedicated mentor to support you throughout your training.")
    end

    context "when viewing the course in Find / not in Publish preview" do
      it "renders a trackable link" do
        result = render_inline(described_class.new(course: course, is_preview: false))

        expect(result).to have_link(
          "Find out what to expect on school placements",
          href: find_track_click_path(
            utm: "school_placement_activities",
            url: I18n.t("find.get_into_teaching.url_type_of_course_provider"),
          ),
        )
      end
    end

    context "when viewing the course in preview mode" do
      it "renders a plain link" do
        result = render_inline(described_class.new(course: course, is_preview: true))

        expect(result).to have_link(
          "Find out what to expect on school placements",
          href: I18n.t("find.get_into_teaching.url_type_of_course_provider"),
        )
      end
    end
  end
end
