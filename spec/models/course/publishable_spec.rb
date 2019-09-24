RSpec.describe Course, type: :model do
  describe "#publishable?" do
    let(:course) { create(:course) }
    let(:site) { create(:site) }
    let(:site_status) { create(:site_status, :new, site: site) }

    subject { course }

    its(:publishable?) { should be_falsey }

    context "with enrichment" do
      let(:enrichment) { build(:course_enrichment, :subsequent_draft, created_at: 1.day.ago) }
      let(:course) {
        create(:course, enrichments: [enrichment], site_statuses: [site_status])
      }

      its(:publishable?) { should be_truthy }
    end

    context "with no enrichment" do
      let(:course) {
        create(:course, site_statuses: [site_status])
      }

      its(:publishable?) { should be_falsey }

      describe "course errors" do
        subject do
          course.publishable?
          course.errors
        end

        it { should_not be_empty }
      end
    end

    context "with no sites" do
      let(:enrichment) { build(:course_enrichment, :subsequent_draft, created_at: 1.day.ago) }
      let(:course) {
        create(:course, site_statuses: [], enrichments: [enrichment])
      }

      its(:publishable?) { should be_falsey }

      describe "course errors" do
        subject do
          course.publishable?
          course.errors
        end

        it { should_not be_empty }
      end
    end
  end
end
