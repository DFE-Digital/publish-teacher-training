RSpec.describe Course, type: :model do
  describe '#publishable?' do
    let(:course) { create(:course) }

    subject { course }

    its(:publishable?) { should be_falsey }

    context 'with enrichment' do
      let(:course) {
        create(:course, with_enrichments: [[:subsequent_draft, created_at: 1.day.ago]])
      }

      its(:publishable?) { should be_truthy }
    end

    context 'with no enrichment' do
      let(:course) {
        create(:course, with_enrichments: [])
      }

      its(:publishable?) { should be_falsey }

      describe 'course errors' do
        subject do
          course.publishable?
          course.errors
        end

        it { should_not be_empty }
      end
    end
  end
end
