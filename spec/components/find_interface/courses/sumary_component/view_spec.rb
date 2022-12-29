# frozen_string_literal: true

require "rails_helper"

module Find::Courses::SummaryComponent
  describe View do
    it "renders sub sections" do
      provider = build(:provider).decorate
      course = create(:course, :draft_enrichment,
        provider:).decorate

      result = render_inline(described_class.new(course))
      expect(result.text).to include(
        "Financial support",
        "Qualification",
        "Course length",
        "Qualification",
        "Date you can apply from",
        "Date course starts",
        "Website",
      )
    end

    context "a course has an accrediting provider that is not the provider" do
      it "renders the accredited body" do
        course = build(
          :course,
          provider: build(:provider),
          accrediting_provider: build(:provider),
        ).decorate

        result = render_inline(described_class.new(course))

        expect(result.text).to include(
                                 "Accredited body",
                               )
      end
    end

    context "the course provider and accrediting provider are the same" do
      it "does not render the accredited body" do
        provider = build(:provider)

        course = build(
          :course,
          provider:,
          accrediting_provider: provider,
        ).decorate

        result = render_inline(described_class.new(course))

        expect(result.text).not_to include(
                                     "Accredited body",
                                   )
      end
    end

    context "secondary course" do
      it "renders the age range and level" do
        course = build(
          :course,
          :secondary,
          provider: build(:provider),
        ).decorate

        result = render_inline(described_class.new(course))

        expect(result.css('[data-qa="course__age_range"]').text).to have_text("11 to 18 - secondary")
      end
    end

    context "non-secondary course" do
      it "render the age range only" do
        course = build(
          :course,
          provider: build(:provider),
        ).decorate

        result = render_inline(described_class.new(course))

        expect(result.css('[data-qa="course__age_range"]').text).to eq("3 to 7")
      end
    end
  end
end
