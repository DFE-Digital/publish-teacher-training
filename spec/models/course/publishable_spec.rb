RSpec.describe Course, type: :model do
  describe '#publishable?' do
    let(:subject) {
      create(:course)
    }

    its(:publishable?) { should eq(false) }

    context 'with enrichment' do
      let(:subject) {
        create(:course, with_enrichments: [[:subsequent_draft, created_at: 1.day.ago]])
      }

      its(:publishable?) { should eq(true) }
    end
  end
end
