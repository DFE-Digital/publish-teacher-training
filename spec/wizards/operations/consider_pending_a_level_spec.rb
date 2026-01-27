# frozen_string_literal: true

require "rails_helper"

RSpec.describe Operations::ConsiderPendingALevel do
  subject(:operation) { described_class.new(repository:, step:) }

  let(:course) { create(:course) }
  let(:repository) { instance_double(DfE::Wizard::Repository::Model, record: course) }
  let(:step) { instance_double(ALevelSteps::ConsiderPendingALevel, accepting_pending_a_level?: accepting_pending_a_level) }
  let(:accepting_pending_a_level) { false }

  describe "#execute" do
    context "when accepting pending A levels" do
      let(:accepting_pending_a_level) { true }

      it "updates course with accept_pending_a_level as true" do
        expect { operation.execute }.to change { course.reload.accept_pending_a_level }.to(true)
      end

      it "returns success" do
        expect(operation.execute).to eq({ success: true })
      end
    end

    context "when not accepting pending A levels" do
      let(:accepting_pending_a_level) { false }

      it "updates course with accept_pending_a_level as false" do
        expect { operation.execute }.to change { course.reload.accept_pending_a_level }.to(false)
      end

      it "returns success" do
        expect(operation.execute).to eq({ success: true })
      end
    end

    context "when an error occurs" do
      before do
        allow(course).to receive(:update).and_raise(StandardError)
      end

      it "returns failure" do
        expect(operation.execute).to eq({ success: false })
      end
    end
  end
end
