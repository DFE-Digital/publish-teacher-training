RSpec.describe Course, type: :model do
  describe '#publishable?' do
    subject { create(:course) }

    its(:publishable?) { should be_falsey }

    context 'with enrichment' do
      let(:enrichment) { create(:course_enrichment, :subsequent_draft, created_at: 1.day.ago) }

      before do
        enrichment.course.enrichments = [enrichment]
      end

      subject { enrichment.course }

      its(:publishable?) { should be_truthy }
    end

    context 'with no enrichment' do
      its(:publishable?) { should be_falsey }

      describe 'course errors' do
        let(:course) { create(:course) }
        subject do
          course.publishable?
          course.errors
        end

        it { should_not be_empty }
      end
    end
  end
end
