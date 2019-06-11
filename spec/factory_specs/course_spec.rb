require 'rails_helper'

describe "Course factory" do
  subject { create(:course) }

  it { should be_instance_of(Course) }
  it { should be_valid }

  context "course resulting_in_pgde" do
    subject { create(:course, :resulting_in_pgde) }
    its(:qualification) { should eq("pgde") }
  end

  context "with_course_enrichments" do
    let(:course) { create(:course, enrichments: [first_enrichment, second_enrichment, third_enrichment]) }
    let(:first_enrichment) { build(:course_enrichment, :published, created_at: 5.days.ago) }
    let(:second_enrichment) { build(:course_enrichment, :published, created_at: 3.days.ago) }
    let(:third_enrichment) { build(:course_enrichment, :subsequent_draft, created_at: 1.day.ago) }


    subject { course }

    it "has enrichments" do
      expect(subject.enrichments.size).to eq(3)

      expect(CourseEnrichment.where('created_at < ?', Time.now).count).to eq(3)
      expect(CourseEnrichment.where('created_at < ?', 2.days.ago).count).to eq(2)
      expect(CourseEnrichment.where('created_at < ?', 4.days.ago).count).to eq(1)
    end
  end
end
