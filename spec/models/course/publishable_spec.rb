RSpec.describe Course, type: :model do
  describe '#publishable?' do
    let(:course) { create(:course) }

    subject { course.publishable? }

    it { should be false }

    context 'with enrichment' do
      let(:course) {
        create(:course, with_enrichments: [[:subsequent_draft, created_at: 1.day.ago]])
      }

      it { should be true }
    end

    context 'with no enrichment' do
      let(:course) {
        create(:course, with_enrichments: [])
      }

      it { should be false }

      describe 'course errors' do
        subject do
          course.publishable?
          course.errors
        end

        it {should_not be_empty}
      end
    end
  end
end
