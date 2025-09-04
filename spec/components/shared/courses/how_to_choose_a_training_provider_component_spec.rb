# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::HowToChooseATrainingProviderComponent, type: :component do
  include Rails.application.routes.url_helpers

  context "the how to choose a training provider callout box displays correctly" do
    let(:provider) { build(:provider, selectable_school: false) }
    let(:course) { build(:course, funding: "fee", provider:).decorate }

    it "renders the correct title and content" do
      result = render_inline(described_class.new(course: course, is_preview: false))

      expect(result).to have_css(".app-callout__title", text: "How to choose a training provider")
      expect(result).to have_css("p.govuk-body", text: "Your course will vary depending on whether the training provider is a university, a school or another organisation.")
    end

    context "when viewing the course in Find / not in Publish preview" do
      it "renders a trackable link" do
        result = render_inline(described_class.new(course: course, is_preview: false))

        expect(result).to have_link(
          "Find out how to choose a training provider",
          href: find_track_click_path(
            utm: "how_to_choose_a_training_provider",
            url: I18n.t("find.get_into_teaching.url_type_of_course_provider"),
          ),
        )
      end
    end

    context "when viewing the course in preview mode" do
      it "renders a plain link" do
        result = render_inline(described_class.new(course: course, is_preview: true))

        expect(result).to have_link(
          "Find out how to choose a training provider",
          href: I18n.t("find.get_into_teaching.url_type_of_course_provider"),
        )
      end
    end
  end
end
