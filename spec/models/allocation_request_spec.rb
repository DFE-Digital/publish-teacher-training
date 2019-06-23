describe AllocationRequest do
  let(:allocation_subject) { "Biology" }
  let(:route) { :higher_education_programme }
  let(:course_aim) { :pgce_with_qts }
  let(:requesting_nctl_organisation) { build(:nctl_organisation, name: 'ACME', ukprn: 12345) }
  let(:partner_nctl_organisation) { build(:nctl_organisation, name: 'Big Uni', ukprn: 67890) }
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

  describe "equality" do
    let(:identical_request) {
      described_class.new(
        requesting_nctl_organisation: allocation_request.requesting_nctl_organisation,
        partner_nctl_organisation: allocation_request.partner_nctl_organisation,
        subject: allocation_request.subject,
        route: allocation_request.route,
        course_aim: allocation_request.course_aim
      )
    }

    let(:request_in_another_subject) {
      described_class.new(
        requesting_nctl_organisation: allocation_request.requesting_nctl_organisation,
        partner_nctl_organisation: allocation_request.partner_nctl_organisation,
        subject: "Mathematics",
        route: allocation_request.route,
        course_aim: allocation_request.course_aim
      )
    }

    subject { [allocation_request, identical_request, request_in_another_subject].uniq }

    describe "depends on the requesting org, partner org, subject, route and aim matching" do
      its(:size) { should eq(2) }
      it { should match_array([allocation_request, request_in_another_subject]) }
    end
  end
end
