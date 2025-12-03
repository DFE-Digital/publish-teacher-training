# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper do
  include ViewHelper
  include GovukVisuallyHiddenHelper
  include GovukComponentsHelper
  include GovukLinkHelper

  describe "#enrichment_error_link" do
    context "with a course" do
      before do
        @provider = build(:provider)
        @course = build(:course, provider: @provider)
      end

      it "returns correct content" do
        expect(enrichment_error_link(:course, "course_length", "Something course length"))
          .to eq("<div class=\"govuk-inset-text app-inset-text--narrow-border app-inset-text--error\"><a class=\"govuk-link\" href=\"/publish/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/length?display_errors=true#course_length-error\">Something course length</a></div>")
      end
    end
  end

  describe "#enrichment_summary" do
    subject { render(summary_list) }

    let(:summary_list) { GovukComponent::SummaryListComponent.new }

    context "with a value" do
      before do
        enrichment_summary(summary_list, :course, "About course", "Something about the course", %w[about])
      end

      it "injects the provided content into the provided summary list row" do
        expect(subject).to have_css(%(.govuk-summary-list__row[data-qa="enrichment__about"]))
        expect(subject).to have_css(".govuk-summary-list__key", text: "About course")
        expect(subject).to have_css(".govuk-summary-list__value", text: "Something about the course")
      end
    end

    context "with errors" do
      before do
        @provider = build_stubbed(:provider)
        @course = build_stubbed(:course, provider: @provider)
        @errors = { course_length: ["Enter course length"] }

        enrichment_summary(summary_list, :course, "Course length", "", [:course_length])
      end

      it "renders a value containing an error link within inset text" do
        expect(subject).to have_css(".govuk-summary-list__key", text: "Course length")
        expect(subject).to have_css(".govuk-summary-list__value > .app-inset-text--error > a", text: "Enter course length")

        expect(subject).to have_link("Enter course length", href: "/publish/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/length?display_errors=true#course_length-error")
      end
    end
  end
end
