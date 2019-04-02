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
    subject {
      create(:course, with_enrichments: [
        [:published, created_at: 5.days.ago],
        [:published, created_at: 3.days.ago],
        [:subsequent_draft, created_at: 1.day.ago],
      ])
    }

    it "has enrichments" do
      expect(subject.enrichments.size).to eq(3)

      expect(CourseEnrichment.where('created_at < ?', Time.now).count).to eq(3)
      expect(CourseEnrichment.where('created_at < ?', 2.days.ago).count).to eq(2)
      expect(CourseEnrichment.where('created_at < ?', 4.days.ago).count).to eq(1)
    end
  end
end
