# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper do
  include ViewHelper
  include Publish::ValueHelper
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

    context "with a blank value and a prompt" do
      before do
        @provider = build_stubbed(:provider)
        @course = build_stubbed(:course, provider: @provider)

        enrichment_summary(summary_list, :course, "Course length", "", %w[course_length],
                           action_path: "/publish/length", prompt: "Enter course length")
      end

      it "renders the prompt instead of the change action" do
        expect(subject).to have_css(".govuk-summary-list__value > .app-inset-text--important > a", text: "Enter course length")
        expect(subject).to have_link("Enter course length", href: "/publish/length")
        expect(subject).to have_no_link("Change")
      end
    end

    context "with a blank value, a prompt and nowhere to send the user" do
      before do
        enrichment_summary(summary_list, :course, "Course length", "", %w[course_length],
                           action_path: nil, prompt: "Enter course length")
      end

      it "falls back to the plain empty value" do
        expect(subject).to have_no_css(".app-inset-text--important")
        expect(subject).to have_css(".govuk-summary-list__value", text: "Empty")
      end
    end

    context "with errors" do
      before do
        @provider = build_stubbed(:provider)
        @course = build_stubbed(:course, provider: @provider)
        @errors = { course_length: ["Enter course length"] }

        enrichment_summary(summary_list, :course, "Course length", "", [:course_length], prompt: "Enter course length")
      end

      it "renders the error rather than the prompt" do
        expect(subject).to have_css(".govuk-summary-list__key", text: "Course length")
        expect(subject).to have_css(".govuk-summary-list__value > .app-inset-text--error > a", text: "Enter course length")

        expect(subject).to have_link("Enter course length", href: "/publish/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/length?display_errors=true#course_length-error")
      end
    end
  end
end
