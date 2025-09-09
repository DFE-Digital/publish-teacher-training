# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::InterviewPreparationComponent, type: :component do
  include Rails.application.routes.url_helpers

  context "the interview preparation callout box displays correctly" do
    let(:provider) { build(:provider, selectable_school: false) }
    let(:course)   { build(:course, funding: "fee", provider:).decorate }

    it "renders the correct title and content" do
      result = render_inline(described_class.new(course: course, is_preview: false))

      expect(result).to have_css(".app-callout__title", text: "Preparing for your interview")
      expect(result).to have_css("p.govuk-body", text: "Interviews sometimes include a presentation, or maths or English tests to be completed in advance. The exact interview process will vary depending on the teacher training provider.")
    end

    context "when viewing the course in Find / not in Publish preview" do
      it "renders a trackable link" do
        result = render_inline(described_class.new(course: course, is_preview: false))

        expect(result).to have_link(
          "Find out how to prepare for your interview.",
          href: find_track_click_path(
            utm: "interview_preparation",
            url: I18n.t("find.get_into_teaching.url_interview_preparation"),
          ),
        )
      end
    end

    context "when viewing the course in preview mode" do
      it "renders a plain link" do
        result = render_inline(described_class.new(course: course, is_preview: true))

        expect(result).to have_link(
          "Find out how to prepare for your interview.",
          href: I18n.t("find.get_into_teaching.url_interview_preparation"),
        )
      end
    end
  end
end
