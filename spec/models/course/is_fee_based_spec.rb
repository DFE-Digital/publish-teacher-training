RSpec.describe Course, type: :model do
  describe '#is_fee_based?' do
    let(:subject) {
      course.is_fee_based?
    }

    context 'salary based course' do
      let(:course) {
        create(:course, :salary_type_based)
      }

      it { should be false }
    end

    context 'salary based course' do
      let(:course) {
        create(:course, :fee_type_based)
      }

      it { should be true }
    end
  end
end
