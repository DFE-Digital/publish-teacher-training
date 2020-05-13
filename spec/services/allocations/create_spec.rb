require "rails_helper"

RSpec.describe Allocations::Create do
  let(:provider) { create(:provider) }
  let(:accredited_body) { create(:provider, :accredited_body) }

  describe "#execute" do
    context "when request_type is declined" do
      subject do
        described_class.new(provider_id: provider.id.to_s,
                            accredited_body_id: accredited_body.id.to_s,
                            request_type: "declined")
      end

      it "sets number of places to 0" do
        subject.execute

        allocation = subject.object

        expect(allocation).to be_persisted
        expect(allocation.number_of_places).to eq(0)
      end
    end

    context "when request type is repeat" do
      subject do
        described_class.new(provider_id: provider.id.to_s,
                            accredited_body_id: accredited_body.id.to_s,
                            request_type: "repeat")
      end

      let(:temporary_repeat_number) { 42 }

      it "set number of places temporarily" do
        subject.execute

        expect(subject.object.number_of_places).to eq(temporary_repeat_number)
      end
    end
  end
end
