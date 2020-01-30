require "rails_helper"

describe "Course factory" do
  subject { create(:course) }

  it { should be_instance_of(Course) }
  it { should be_valid }
  it "has the correct number of associations" do
    expect { subject }.to change { Provider.count }.by(1)
  end

  context "course resulting_in_pgde" do
    subject { create(:course, :resulting_in_pgde) }
    its(:qualification) { should eq("pgde") }
  end

  context "with_course_enrichments" do
    let(:first_enrichment) { build(:course_enrichment, :published, created_at: 3.days.ago) }
    let(:second_enrichment) { build(:course_enrichment, :published, created_at: 5.days.ago) }
    let(:third_enrichment) { build(:course_enrichment, :subsequent_draft, created_at: 1.day.ago) }

    let(:enrichments) { [first_enrichment, second_enrichment, third_enrichment] }

    subject {
      create(:course, enrichments: enrichments)
    }

    it "has enrichments" do
      expect(subject.enrichments.size).to eq(3)

      expect(CourseEnrichment.where("created_at < ?", Time.zone.now).count).to eq(3)
      expect(CourseEnrichment.where("created_at < ?", 2.days.ago).count).to eq(2)
      expect(CourseEnrichment.where("created_at < ?", 4.days.ago).count).to eq(1)
    end
  end

  context "unpublished" do
    subject { create(:course, :unpublished) }

    its(:name) { should eq("unpublished course name") }

    it "has the correct number of associations" do
      expect { subject }.to change { Site.count }.by(1).and change { Provider.count }.by(1)
    end

    it "has the correct association" do
      provider_id = subject.provider.id

      expect(subject.sites.first.provider_id == provider_id)
    end
  end
end
