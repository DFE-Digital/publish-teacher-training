describe Subjects::FinancialIncentiveCreatorService do
  let(:subject_spy) { spy }
  let(:financial_incentive_spy) { spy }

  let(:service) do
    described_class.new(
      subject: subject_spy,
      financial_incentive: financial_incentive_spy,
    )
  end

  before do
    allow(subject_spy).to receive(:where).and_return %w[anything anything anything]
  end

  it "creates subject financial incentive data unless subject financial incentive already exists" do
    service.execute
    expect(subject_spy).to have_received(:where).exactly(10).times
    expect(financial_incentive_spy).to have_received(:find_or_create_by).exactly(30).times
  end
end
