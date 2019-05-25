describe DFESubject do
  subject { DFESubject.new(subject_name) }

  context "(secondary mathematics)" do
    let(:subject_name) { "Mathematics" }

    it { should have_bursary }
    it { should have_scholarship }
    it { should have_early_career_payments }

    it { should eq(DFESubject.new("Mathematics")) }

    it 'returns the #bursary_amount' do
      expect(subject.bursary_amount).to be_present
    end

    it 'returns the #scholarship_amount' do
      expect(subject.scholarship_amount).to be_present
    end
  end

  context "(physical education)" do
    let(:subject_name) { "Physical education" }

    it { should_not have_bursary }
    it { should_not have_scholarship }
    it { should_not have_early_career_payments }

    it 'returns the #bursary_amount' do
      expect(subject.bursary_amount).to_not be_present
    end

    it 'returns the #scholarship_amount' do
      expect(subject.scholarship_amount).to_not be_present
    end
  end
end
