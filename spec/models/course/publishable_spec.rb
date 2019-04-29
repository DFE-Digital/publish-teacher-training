RSpec.describe Course, type: :model do
  describe '#publishable?' do
    let(:course) {
      create(:course)
    }

    let!(:subject) {
      course.publishable?
    }

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
      it 'added errors' do
        expect(course.errors.empty?).to be false
      end
    end
  end
end
