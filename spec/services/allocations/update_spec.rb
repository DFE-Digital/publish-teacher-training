require "rails_helper"

RSpec.describe Allocations::Update do
  describe "#execute" do
    context "when request type is changed from repeat to declined" do
      let(:repeat_allocation) { create(:allocation, :repeat, number_of_places: 2) }
      let(:params) { { request_type: "declined" } }
      subject do
        described_class.new(repeat_allocation, params).execute
      end

      it "returns true" do
        expect(subject).to be(true)
      end

      it "sets the number of places to 0" do
        expect { subject }.to(
          change { repeat_allocation.reload.number_of_places }.to(0),
        )
      end

      it "changes the request_type to declined" do
        expect { subject }.to(
          change { repeat_allocation.reload.request_type }.to("declined"),
        )
      end
    end

    context "when request type is changed from declined to repeat" do
      context "when there are no previous allocations" do
        let(:declined_allocation) { create(:allocation, :declined) }
        let(:params) { { request_type: "repeat" } }

        subject do
          described_class.new(declined_allocation, params).execute
        end

        it "returns true" do
          expect(subject).to be(true)
        end

        it "doesn't change the number of places" do
          expect { subject }.not_to(
            change { declined_allocation.reload.number_of_places },
          )
        end

        it "changes the request_type to repeat" do
          expect { subject }.to(
            change { declined_allocation.reload.request_type }.to("repeat"),
          )
        end
      end

      context "when there is a previous allocation" do
        let(:provider) { create(:provider) }
        let(:accredited_body) { create(:provider, :accredited_body) }
        let(:previous_recruitment_cycle) do
          create(:recruitment_cycle, year: RecruitmentCycle.current.year.to_i - 1)
        end

        let(:previous_number_of_places) { rand(1..99) }
        let!(:previous_allocation) do
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

        let(:declined_allocation) do
          create(
            :allocation,
            :declined,
            provider_id: provider.id,
            accredited_body_id: accredited_body.id,
            number_of_places: 0,
            provider_code: provider.provider_code,
            accredited_body_code: accredited_body.provider_code,
          )
        end

        let(:params) { { request_type: "repeat" } }

        subject do
          described_class.new(declined_allocation, params).execute
        end

        it "returns true" do
          expect(subject).to be(true)
        end

        it "sets number of places to the previous allocation's" do
          expect { subject }.to(
            change { declined_allocation.reload.number_of_places }.to(previous_number_of_places),
          )
        end

        it "changes the request_type to repeat" do
          expect { subject }.to(
            change { declined_allocation.reload.request_type }.to("repeat"),
          )
        end
      end
    end

    context "when the request type is initial with 2 places" do
      context "the number of places increase to 4" do
        let(:initial_allocation) { create(:allocation, :initial, number_of_places: 2) }
        let(:params) { { request_type: "initial", number_of_places: 4 } }

        subject do
          described_class.new(initial_allocation, params).execute
        end

        it "returns true" do
          expect(subject).to be(true)
        end

        it "sets number of places to 4" do
          expect { subject }.to(
            change { initial_allocation.reload.number_of_places }.to(4),
          )
        end

        it "doesn't change the request type" do
          expect { subject }.not_to(
            change { initial_allocation.reload.request_type },
          )
        end
      end

      context "a paramater isn't valid" do
        let(:initial_allocation) { create(:allocation, :initial, number_of_places: 2) }

        context "the number of places isn't a number" do
          let(:params) { { request_type: "initial", number_of_places: "foo" } }

          subject do
            described_class.new(initial_allocation, params).execute
          end

          it "returns false" do
            expect(subject).to be(false)
          end
        end
      end
    end
  end
end
