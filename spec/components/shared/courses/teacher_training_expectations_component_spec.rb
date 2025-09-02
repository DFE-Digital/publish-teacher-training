# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::TeacherTrainingExpectationsComponent, type: :component do
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

      expect(result).to have_css(".app-callout__title", text: "What to expect in teacher training")
      expect(result).to have_css("p.govuk-body", text: "You'll spend most of your time teaching in a classroom, with some time dedicated to studying. This may include seminars, workshops and assignments.")
      expect(result).to have_link(
        "Find out what to expect in teacher training",
        href: I18n.t("find.get_into_teaching.url_initial_teacher_training"),
      )
    end
  end
end
