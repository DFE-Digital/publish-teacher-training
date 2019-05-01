RSpec.describe Course, type: :model do
  describe '#is_fee_based?' do
    context 'salary based course' do
      subject { create(:course, :salary_type_based) }

      its(:is_fee_based?) { should be_falsey }
    end

    context 'fee based course' do
      subject { create(:course, :fee_type_based) }

      its(:is_fee_based?) { should be_truthy }
    end
  end
end
