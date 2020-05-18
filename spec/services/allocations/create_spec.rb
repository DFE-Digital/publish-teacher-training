require "rails_helper"

RSpec.describe Allocations::Create do
  let(:provider) { create(:provider) }
  let(:accredited_body) { create(:provider, :accredited_body) }
  let(:previous_recruitment_cycle) do
    create(:recruitment_cycle, year: RecruitmentCycle.current.year.to_i - 1)
  end

  describe "#execute" do
    context "when request_type is declined" do
      subject do
        described_class.new(
          provider_id: provider.id.to_s,
          accredited_body_id: accredited_body.id.to_s,
          request_type: "declined",
        )
      end

      it "sets number of places to 0" do
        subject.execute

        allocation = subject.object

        expect(allocation).to be_persisted
        expect(allocation.number_of_places).to eq(0)
      end
    end

    context "when request type is repeat" do
      let(:previous_number_of_places) { rand(1..99) }

      let(:previous_allocation) do
        create(
          :allocation,
          provider_id: provider.id,
          accredited_body_id: accredited_body.id,
          number_of_places: previous_number_of_places,
          recruitment_cycle: previous_recruitment_cycle,
          provider_code: provider.provider_code,
          accredited_body_code: accredited_body.provider_code,
        )
      end

      before do
        previous_allocation
      end

      subject do
        described_class.new(
          provider_id: provider.id.to_s,
          accredited_body_id: accredited_body.id.to_s,
          request_type: "repeat",
        )
      end

      it "set number of places to previous allocation" do
        subject.execute

        expect(subject.object.number_of_places).to eq(previous_number_of_places)
      end
    end
  end
end
