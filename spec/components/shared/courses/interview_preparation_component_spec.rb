# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::InterviewPreparationComponent, type: :component do
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

      expect(result).to have_css(".app-callout__title", text: "Preparing for your interview")
      expect(result).to have_css("p.govuk-body", text: "Interviews sometimes include a presentation, or maths or English tests to be completed in advance. The exact interview process will vary depending on the teacher training provider.")
      expect(result).to have_link(
        "Find out how to prepare for your interview",
        href: I18n.t("find.get_into_teaching.url_interview_preparation"),
      )
    end
  end
end
