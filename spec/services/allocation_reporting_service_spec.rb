require "rails_helper"

describe AllocationReportingService do
  let(:previous) do
    {
      total: {
        allocations: 666,
        distinct_accredited_bodies: 321,
        distinct_providers: 222,
        number_of_places: 6666,
      },
    }
  end

  let(:current) do
    {
      total: {
         allocations: 999,
         distinct_accredited_bodies: 123,
         distinct_providers: 333,
         number_of_places: 9999,
      },
    }
  end

  let(:expected) do
    {
      previous: previous,
      current: current,
    }
  end

  let(:recruitment_cycle_scope) { instance_double(RecruitmentCycle) }

  let(:current_recruitment_cycle_scope) { recruitment_cycle_scope }
  let(:previous_recruitment_cycle_scope) { instance_double(RecruitmentCycle) }

  let(:current_requested_allocations_scope) { class_double(Allocation) }
  let(:previous_requested_allocations_scope) { class_double(Allocation) }

  let(:current_distinct_requested_allocations_scope) { class_double(Allocation) }
  let(:previous_distinct_requested_allocations_scope) { class_double(Allocation) }

  let(:current_distinct_accredited_bodies_scope) { class_double(Allocation) }
  let(:previous_distinct_accredited_bodies_scope) { class_double(Allocation) }

  let(:current_distinct_providers_scope) { class_double(Allocation) }
  let(:previous_distinct_providers_scope) { class_double(Allocation) }

  describe ".call" do
    describe "when scope is passed" do
      subject { described_class.call(recruitment_cycle_scope: recruitment_cycle_scope) }

      it "applies the scopes" do
        expect(recruitment_cycle_scope).to receive_message_chain(:previous).and_return(previous_recruitment_cycle_scope)

        expect(current_recruitment_cycle_scope).to receive_message_chain(:allocations, :not_declined).and_return(current_requested_allocations_scope)
        expect(previous_recruitment_cycle_scope).to receive_message_chain(:allocations, :not_declined).and_return(previous_requested_allocations_scope)

        expect(current_requested_allocations_scope).to receive_message_chain(:count).and_return(999)
        expect(previous_requested_allocations_scope).to receive_message_chain(:count).and_return(666)

        expect(current_requested_allocations_scope).to receive_message_chain(:distinct).and_return(current_distinct_requested_allocations_scope)
        expect(previous_requested_allocations_scope).to receive_message_chain(:distinct).and_return(previous_distinct_requested_allocations_scope)

        expect(current_distinct_requested_allocations_scope).to receive_message_chain(:select).with(:accredited_body_id).and_return(current_distinct_accredited_bodies_scope)
        expect(previous_distinct_requested_allocations_scope).to receive_message_chain(:select).with(:accredited_body_id).and_return(previous_distinct_accredited_bodies_scope)

        expect(current_distinct_accredited_bodies_scope).to receive_message_chain(:count).and_return(123)
        expect(previous_distinct_accredited_bodies_scope).to receive_message_chain(:count).and_return(321)

        expect(current_distinct_requested_allocations_scope).to receive_message_chain(:select).with(:provider_id).and_return(current_distinct_providers_scope)
        expect(previous_distinct_requested_allocations_scope).to receive_message_chain(:select).with(:provider_id).and_return(previous_distinct_providers_scope)

        expect(current_distinct_providers_scope).to receive_message_chain(:count).and_return(333)
        expect(previous_distinct_providers_scope).to receive_message_chain(:count).and_return(222)

        expect(current_requested_allocations_scope).to receive_message_chain(:sum).with(:number_of_places).and_return(9999)
        expect(previous_requested_allocations_scope).to receive_message_chain(:sum).with(:number_of_places).and_return(6666)

        expect(subject).to eq(expected)
      end
    end
  end
end
