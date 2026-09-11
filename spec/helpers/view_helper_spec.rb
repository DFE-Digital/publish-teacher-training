# frozen_string_literal: true

require "rails_helper"

describe ViewHelper do
  include PreviewHelper
  include Rails.application.routes.url_helpers

  describe "#enrichment_error_url" do
    let(:provider) { build(:provider, recruitment_cycle: build(:recruitment_cycle)) }
    let(:course) { build(:course, provider:) }

    it "returns enrichment error URL" do
      expect(enrichment_error_url(provider_code: "A1", course:, field: "course_length")).to eq("/publish/organisations/A1/#{course.recruitment_cycle_year}/courses/#{course.course_code}/length?display_errors=true#course_length-error")
    end

    it "returns enrichment error URL for base error" do
      expect(enrichment_error_url(provider_code: "A1", course:, field: "base", message: "Select if student visas can be sponsored")).to eq("/publish/organisations/A1/#{Find::CycleTimetable.current_year}/student-visa")
    end

    it "returns the course applications open date url for the error" do
      expect(enrichment_error_url(provider_code: provider.provider_code, course:, field: "applications_open_from")).to eq("/publish/organisations/#{provider.provider_code}/#{Find::CycleTimetable.current_year}/courses/#{course.course_code}/applications-open")
    end
  end

  describe "#ordered_enrichment_errors" do
    let(:degree_message) { I18n.t("activerecord.errors.models.course.attributes.base.degree_requirements_not_publishable") }
    let(:gcse_message) { I18n.t("activerecord.errors.models.course.attributes.base.gcse_requirements_not_publishable") }

    it "orders the errors the way the rows are ordered on the description tab" do
      errors = {
        theoretical_training_activities: ["Enter what trainees will study"],
        placement_school_activities: ["Enter what trainees will do on school placements"],
        course_length: ["Enter course length"],
        base: [degree_message, gcse_message],
        a_level_subject_requirements: ["Enter A levels and equivalency test requirements"],
      }

      expect(ordered_enrichment_errors(errors).map(&:last)).to eq(
        [
          "Enter course length",
          degree_message,
          "Enter A levels and equivalency test requirements",
          gcse_message,
          "Enter what trainees will do on school placements",
          "Enter what trainees will study",
        ],
      )
    end

    it "keeps the field alongside each message so the summary can still link to it" do
      errors = { course_length: ["Enter course length"], base: [gcse_message] }

      expect(ordered_enrichment_errors(errors)).to eq(
        [[:course_length, "Enter course length"], [:base, gcse_message]],
      )
    end

    it "puts fields it does not know about last, in the order they arrived" do
      errors = { sites: ["Enter schools for this course"], subjects: ["Select a subject"], course_length: ["Enter course length"] }

      expect(ordered_enrichment_errors(errors).map(&:first)).to eq(%i[course_length sites subjects])
    end

    it "orders the base messages it does not know about after the ones it does" do
      errors = { base: ["Select if visas can be sponsored", gcse_message] }

      expect(ordered_enrichment_errors(errors).map(&:last)).to eq([gcse_message, "Select if visas can be sponsored"])
    end
  end

  describe "#provider_enrichment_error_url" do
    let(:provider) { build(:provider) }

    it "returns provider enrichment error URL" do
      expect(provider_enrichment_error_url(provider:, field: "email")).to eq("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/contact?display_errors=true#provider_email")
    end
  end

  describe "#x_provider_url" do
    let(:course) { create(:course) }

    context "when preview? is true" do
      def preview?(_) = true

      it "returns the publish provider url" do
        expect(x_provider_url).to eq(
          provider_publish_provider_recruitment_cycle_course_path(
            course.provider_code,
            course.recruitment_cycle_year,
            course.course_code,
          ),
        )
      end
    end

    context "when preview? is false" do
      def preview?(_) = false

      it "returns the find provider url" do
        expect(x_provider_url).to eq(
          find_provider_path(course.provider_code, course.course_code),
        )
      end
    end
  end

  describe "#x_accrediting_provider_url\n" do
    let(:course) { create(:course) }

    context "when preview? is true" do
      def preview?(_) = true

      it "returns the publish accrediting provider url" do
        expect(x_accrediting_provider_url).to eq(
          ratified_by_publish_provider_recruitment_cycle_course_path(
            course.provider_code,
            course.recruitment_cycle_year,
            course.course_code,
          ),
        )
      end
    end

    context "when preview? is false" do
      def preview?(_) = false

      it "returns the find accrediting provider url" do
        expect(x_accrediting_provider_url).to eq(
          find_accrediting_provider_path(course.provider_code, course.course_code),
        )
      end
    end
  end
end
