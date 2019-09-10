RSpec.describe Course, type: :model do
  describe '#assign_program_type' do
    before do
      subject.assign_program_type(funding_type)
    end

    describe 'when funding type is salary' do
      let(:subject) { create(:course, :with_accrediting_provider) }
      let(:funding_type) { 'salary' }

      its(:program_type) { should eq('school_direct_salaried_training_programme') }
    end

    describe 'when funding type is apprenticeship' do
      let(:subject) { create(:course, :with_scitt) }
      let(:funding_type) { 'apprenticeship' }
      its(:program_type) { should eq('pg_teaching_apprenticeship') }
    end

    describe 'when funding type is fee' do
      let(:funding_type) { 'fee' }

      context 'an externally accredited course' do
        let(:subject) { create(:course, :with_accrediting_provider) }
        its(:program_type) { should eq('school_direct_training_programme') }
      end

      context 'a SCITTs self accredited course' do
        let(:provider) { build(:provider, scitt: 'Y') }
        let(:subject) { create(:course, provider: provider) }

        its(:program_type) { should eq('scitt_programme') }
      end

      context 'a HEIs self accredited course' do
        let(:subject) { create(:course) }
        its(:program_type) { should eq('higher_education_programme') }
      end
    end
  end
end
