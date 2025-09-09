# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::TeacherTrainingExpectationsComponent, type: :component do
  include Rails.application.routes.url_helpers

  context "the teacher training expectations callout box displays correctly" do
    let(:provider) { build(:provider, selectable_school: false) }
    let(:course) { build(:course, funding: "fee", provider:).decorate }

    it "renders the correct title and content" do
      result = render_inline(described_class.new(course: course, is_preview: false))

      expect(result).to have_css(".app-callout__title", text: "What to expect in teacher training")
      expect(result).to have_css("p.govuk-body", text: "You'll spend most of your time teaching in a classroom, with some time dedicated to studying. This may include seminars, workshops and assignments.")
    end

    context "when viewing the course in Find / not in Publish preview" do
      it "renders a trackable link" do
        result = render_inline(described_class.new(course: course, is_preview: false))
        expect(result).to have_link(
          "Find out what to expect in teacher training.",
          href: find_track_click_path(
            utm: "teacher_training_expectations",
            url: I18n.t("find.get_into_teaching.url_initial_teacher_training"),
          ),
        )
      end
    end

    context "when viewing the course in preview mode" do
      it "renders a plain link" do
        result = render_inline(described_class.new(course: course, is_preview: true))

        expect(result).to have_link(
          "Find out what to expect in teacher training.",
          href: I18n.t("find.get_into_teaching.url_initial_teacher_training"),
        )
      end
    end
  end
end
