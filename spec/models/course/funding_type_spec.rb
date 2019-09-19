RSpec.describe Course, type: :model do
  describe '#funding_type' do
    describe 'higher education programme' do
      subject { create(:course, :with_higher_education) }

      its(:funding_type) { should eq 'fee' }
    end

    describe 'scitt programme' do
      subject { create(:course, :with_scitt) }

      its(:funding_type) { should eq 'fee' }
    end

    describe 'school direct programme' do
      subject { create(:course, :with_school_direct) }

      its(:funding_type) { should eq 'fee' }
    end

    describe 'school direct salaired programme' do
      subject { create(:course, :with_salary) }

      its(:funding_type) { should eq 'salary' }
    end

    describe 'pg teaching apprenticeship programme' do
      subject { create(:course, :with_apprenticeship) }

      its(:funding_type) { should eq 'apprenticeship' }
    end
  end
end
