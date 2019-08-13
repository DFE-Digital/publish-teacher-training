RSpec.describe Course, type: :model do
  describe '#update_valid' do
    context 'applications_open_from' do
      let(:course) { create(:course, applications_open_from: DateTime.new(2018, 10, 1)) }

      subject { course }

      context 'for the current recruitment cycle' do
        context 'with a valid date' do
          its(:update_valid?) { should be true }
        end

        context 'with an invalid date' do
          let(:course) { create(:course, applications_open_from: DateTime.new(2019, 10, 1)) }
          its(:update_valid?) { should be false }
        end
      end

      context 'for the next recruitment cycle' do
        let(:provider) { build(:provider, recruitment_cycle: next_recruitment_cycle) }
        let(:next_recruitment_cycle) { create(:recruitment_cycle, year: '2020') }

        context 'with a valid date' do
          let(:course) { create(:course, provider: provider, applications_open_from: DateTime.new(2019, 10, 1)) }
          its(:update_valid?) { should be true }
        end

        context 'with an invalid date' do
          let(:course) { create(:course, provider: provider, applications_open_from: DateTime.new(2018, 10, 1)) }
          its(:update_valid?) { should be false }
        end
      end
    end

    context 'start_date' do
      let(:course) { create(:course, start_date: DateTime.new(2019, 9, 1)) }

      subject { course }

      context 'for the current recruitment cycle' do
        context 'with a valid start date' do
          its(:update_valid?) { should be true }
        end

        context 'with an invalid start date' do
          let(:course) { create(:course, start_date: DateTime.new(2020, 9, 1)) }
          its(:update_valid?) { should be false }
        end
      end

      context 'for the next recruitment cycle' do
        let(:provider) { build(:provider, recruitment_cycle: next_recruitment_cycle) }
        let(:next_recruitment_cycle) { create(:recruitment_cycle, year: '2020') }

        context 'with a valid start date' do
          let(:course) { create(:course, provider: provider, start_date: DateTime.new(2020, 9, 1)) }
          its(:update_valid?) { should be true }
        end

        context 'with an invalid start date' do
          let(:course) { create(:course, provider: provider, start_date: DateTime.new(2019, 9, 1)) }
          its(:update_valid?) { should be false }
        end
      end
    end
  end
end
