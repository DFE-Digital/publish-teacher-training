require "rails_helper"

describe FindInterface::Courses::FeesComponent::View, type: :component do
  context "for international fees" do
    it "renders the correct text" do
      course = create(:course,
        enrichments: [create(:course_enrichment, :published)],
        provider: build(:provider)).decorate

      result = render_inline(described_class.new(course))
      expect(result.text).to include("Student type")
      expect(result.text).to include("Fees to pay")
      expect(result.text).to include("UK students")
      expect(result.text).to include("International students")
      expect(result.text).not_to include("The course fees for UK students")
    end
  end

  context "for uk fees" do
    it "renders the correct text" do
      course = create(:course,
        enrichments: [create(:course_enrichment, :published, fee_international: nil)],
        provider: build(:provider)).decorate

      result = render_inline(described_class.new(course))
      expect(result.text).not_to include("International students")
      expect(result.text).to include("The course fees for UK students")
    end
  end
end
