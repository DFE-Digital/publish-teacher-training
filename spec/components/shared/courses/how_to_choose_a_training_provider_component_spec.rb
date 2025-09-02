# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::HowToChooseATrainingProviderComponent, type: :component do
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

      expect(result).to have_css(".app-callout__title", text: "How to choose a training provider")
      expect(result).to have_css("p.govuk-body", text: "Your course will vary depending on whether the training provider is a university, a school or another organisation.")
      expect(result).to have_link(
        "Find out how to choose a training provider",
        href: I18n.t("find.get_into_teaching.url_type_of_course_provider"),
      )
    end
  end
end
