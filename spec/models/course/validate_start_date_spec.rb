RSpec.describe Course, type: :model do
  describe '#validate_start_date' do
    let(:course) { create(:course, start_date: DateTime.new(2019,9,1)) }

    subject { course }

    context 'for the current recruitment cycle' do
      context 'with a valid start date' do
        its(:validate_start_date) { should be true }
      end

      context 'with an invalid start date' do
        let(:course) { create(:course, start_date: DateTime.new(2020,9,1)) }
        its(:validate_start_date) { should be false }
      end
    end

    context 'for the next recruitment cycle' do
      let(:provider) { build(:provider, recruitment_cycle: next_recruitment_cycle) }
      let(:next_recruitment_cycle) { create(:recruitment_cycle, year: '2020') }

      context 'with a valid start date' do
        let(:course) { create(:course, provider: provider, start_date: DateTime.new(2020,9,1)) }
        its(:validate_start_date) { should be true }
      end

      context 'with an invalid start date' do
        let(:course) { create(:course, provider: provider, start_date: DateTime.new(2019,9,1)) }
        its(:validate_start_date) { should be false }
      end
    end
  end
end
