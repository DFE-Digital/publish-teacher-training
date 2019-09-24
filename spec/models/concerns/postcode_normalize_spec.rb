describe PostcodeNormalize do
  # TODO: Create a test object to use this on instead.
  let(:object) { Site.new }

  subject { object }

  describe "#postcode" do
    let(:postcode) { "sw1a1aa" }

    before do
      subject.postcode = postcode
    end

    it "normalises postcode" do
      expect(subject.postcode).to eq "SW1A 1AA"
    end

    context "with a bad postcode" do
      let(:postcode) { "really bad postcode dawg" }

      it "does not do formatting" do
        expect(subject.postcode).to eq "really bad postcode dawg"
      end
    end
  end
end
