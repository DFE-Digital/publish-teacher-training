# frozen_string_literal: true

require "rails_helper"

module GcseRowContentComponent
  describe View, type: :component do
    let(:provider) { build(:provider) }

    context "when the gcse section is incomplete" do
      it "renders a link to the gcse section" do
        course = build(
          :course,
          provider:,
          accept_pending_gcse: nil,
          accept_gcse_equivalency: nil,
          accept_english_gcse_equivalency: nil,
          accept_maths_gcse_equivalency: nil,
          accept_science_gcse_equivalency: nil,
          additional_gcse_equivalencies: nil,
        )

        render_inline(described_class.new(course: course.decorate))

        expect(page.has_link?(
          "Enter GCSE and equivalency test requirements",
          href: Rails.application.routes.url_helpers.gcses_pending_or_equivalency_tests_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            provider.recruitment_cycle.year,
            course.course_code,
          ),
        )).to be true
      end
    end

    context "when the gcse section is complete" do
      context "when pending gcse's are allowed" do
        it "renders 'Candidates with pending GCSEs will be considered'" do
          course = build(
            :course,
            provider:,
            accept_pending_gcse: true,
            accept_gcse_equivalency: true,
          )

          render_inline(described_class.new(course: course.decorate))

          expect(page).to have_content("Candidates with pending GCSEs will be considered")
        end

        it "renders 'Candidates with pending GCSEs will not be considered'" do
          course = build(
            :course,
            provider:,
            accept_pending_gcse: false,
            accept_gcse_equivalency: true,
          )

          render_inline(described_class.new(course: course.decorate))

          expect(page).to have_content("Candidates with pending GCSEs will not be considered")
        end
      end

      context "when course is primary" do
        it "renders 'Grade 4 (C) or above in English, maths and science, or equivalent qualification'" do
          course = build(
            :course,
            provider:,
            accept_pending_gcse: true,
            accept_gcse_equivalency: true,
            level: "primary",
          )

          render_inline(described_class.new(course: course.decorate))

          expect(page).to have_content("Grade 4 (C) or above in English, maths and science, or equivalent qualification")
        end
      end

      context "when course is secondary" do
        it "renders 'Grade 4 (C) or above in English and maths, or equivalent qualification'" do
          course = build(
            :course,
            provider:,
            accept_pending_gcse: true,
            accept_gcse_equivalency: true,
            level: "secondary",
          )

          render_inline(described_class.new(course: course.decorate))

          expect(page).to have_content("Grade 4 (C) or above in English and maths, or equivalent qualification")
        end
      end

      context "when course is not primary or secondary" do
        it "does not render conditional content" do
          course = build(
            :course,
            provider:,
            level: "Further education",
          )

          render_inline(described_class.new(course: course.decorate))

          expect(page).not_to have_content("Grade 4 (C) or above in English and maths, or equivalent qualification")
          expect(page).not_to have_content("Grade 4 (C) or above in English, maths and science, or equivalent qualification")
        end
      end

      context "when no equivalencies are selected" do
        it "renders the correct content" do
          course = build(
            :course,
            provider:,
            accept_pending_gcse: true,
            accept_gcse_equivalency: false,
            additional_gcse_equivalencies: nil,
          )

          render_inline(described_class.new(course: course.decorate))

          expect(page).to have_content("Equivalency tests will not be accepted")
        end
      end

      context "when one equivalency is selected" do
        it "renders the correct content" do
          course = build(
            :course,
            provider:,
            accept_pending_gcse: true,
            accept_gcse_equivalency: true,
            accept_english_gcse_equivalency: true,
          )

          render_inline(described_class.new(course: course.decorate))

          expect(page).to have_content("Equivalency tests will be accepted in English")
        end
      end

      context "when two equivalencies are selected" do
        it "renders the correct content" do
          course = build(
            :course,
            provider:,
            accept_pending_gcse: true,
            accept_gcse_equivalency: true,
            accept_english_gcse_equivalency: true,
            accept_science_gcse_equivalency: true,
          )

          render_inline(described_class.new(course: course.decorate))

          expect(page).to have_content("Equivalency tests will be accepted in English or science")
        end
      end

      context "when all equivalencies are selected" do
        it "renders the correct content" do
          course = build(
            :course,
            provider:,
            accept_pending_gcse: true,
            accept_gcse_equivalency: true,
            accept_english_gcse_equivalency: true,
            accept_maths_gcse_equivalency: true,
            accept_science_gcse_equivalency: true,
          )

          render_inline(described_class.new(course: course.decorate))

          expect(page).to have_content("Equivalency tests will be accepted in English, maths or science")
        end
      end

      context "when additional_gcse_requirements are given" do
        it "renders the correct content" do
          course = build(
            :course,
            provider:,
            accept_pending_gcse: true,
            accept_gcse_equivalency: true,
            additional_gcse_equivalencies: "Geography",
          )

          render_inline(described_class.new(course: course.decorate))

          expect(page).to have_content("Geography")
        end
      end
    end

    describe "#inset_text_css_classes" do
      context "no relevant error exists" do
        it "does not return an css class" do
          expect(described_class.new(course: nil, errors: nil).inset_text_css_classes).to eq("app-inset-text--narrow-border app-inset-text--important")
        end
      end

      context "a relevant error exists" do
        it "returns an error css class" do
          errors = double("errors", { values: ["Enter GCSE requirements"] })
          expect(described_class.new(course: nil, errors:).inset_text_css_classes).to eq("app-inset-text--narrow-border app-inset-text--error")
        end
      end
    end
  end
end
