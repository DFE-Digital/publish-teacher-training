describe AllocationRequest do
  let(:allocation_subject) { "Biology" }
  let(:route) { :higher_education_programme }
  let(:course_aim) { :pgce_with_qts }
  let(:requesting_nctl_organisation) { build(:nctl_organisation, name: 'ACME', ukprn: 12345) }
  let(:allocation_request) {
    described_class.new(
      requesting_nctl_organisation: requesting_nctl_organisation,
      partner_nctl_organisation: partner_nctl_organisation,
      subject: allocation_subject,
      route: route,
      course_aim: course_aim
    )
  }

  describe "#to_a" do
    subject { allocation_request.to_a }

    context "for unaccredited organisations" do
      let(:partner_nctl_organisation) { build(:nctl_organisation, name: 'Big Uni', ukprn: 67890) }

      its([0]) { should eq('2020/21') }
      its([1]) { should eq('ACME') }
      its([2]) { should eq('12345') }
      its([3]) { should eq('Big Uni') }
      its([4]) { should eq('67890') }
      its([5]) { should eq('Biology') }
      its([6]) { should eq('Provider-led') }
      its([7]) { should eq('QTS plus academic award') }
      its([8]) { should eq('PG') }
    end

    context "for self-accredited requesters" do
      let(:partner_nctl_organisation) { nil }

      its([3]) { should eq('') }
      its([4]) { should eq('') }
    end
  end
end
