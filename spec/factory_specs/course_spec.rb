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
    let(:course) { first_enrichment.course }
    let(:first_enrichment) { create(:course_enrichment, :published, created_at: 5.days.ago) }
    let(:second_enrichment) { create(:course_enrichment, :published, created_at: 3.days.ago, course: course) }
    let(:third_enrichment) { create(:course_enrichment, :subsequent_draft, created_at: 1.day.ago, course: course) }

    before do
      course.enrichments = [first_enrichment, second_enrichment, third_enrichment]
    end

    subject { course }

    it "has enrichments" do
      expect(subject.enrichments.size).to eq(3)

      expect(CourseEnrichment.where('created_at < ?', Time.now).count).to eq(3)
      expect(CourseEnrichment.where('created_at < ?', 2.days.ago).count).to eq(2)
      expect(CourseEnrichment.where('created_at < ?', 4.days.ago).count).to eq(1)
    end
  end
end
