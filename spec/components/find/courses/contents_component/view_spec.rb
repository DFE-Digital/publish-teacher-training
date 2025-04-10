# frozen_string_literal: true

require "rails_helper"

describe Find::Courses::ContentsComponent::View, type: :component do
  context "when the course has details about school placements" do
    it "renders the schools section link" do
      provider = build(:provider)

      course = create(
        :course,
        provider:,
        enrichments: [build(:course_enrichment, :published, how_school_placements_work: "test")],
      ).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("Where you will train")
    end
  end

  context "when the course has study sites" do
    it "renders the schools section link" do
      provider = build(:provider)

      course = build(
        :course,
        provider:,
        study_sites: [Site.new],
      ).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("Where you will train")
    end
  end

  context "when the course has many site statuses" do
    it "renders the schools section link" do
      provider = build(:provider)

      course = create(
        :course,
        provider:,
        site_statuses: [build(:site_status), build(:site_status)],
      ).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("Where you will train")
    end
  end

  context "when previewing the course" do
    it "renders the schools section link" do
      course = build(:course).decorate
      component = described_class.new(course)
      allow_any_instance_of(ActionController::Base).to receive(:params).and_return(action: "preview")

      result = render_inline(component)

      expect(result.text).to include("Where you will train")
    end
  end

  context "when the course is open" do
    it "does render the apply link" do
      provider = build(:provider)
      course = build(:course, :open, provider:).decorate
      result = render_inline(described_class.new(course))

      expect(result.text).to include("Apply")
    end
  end

  context "when the course is not open" do
    it "does not render the apply link" do
      provider = build(:provider)
      course = build(:course, :closed, provider:).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).not_to include("Apply")
    end
  end
end
