# frozen_string_literal: true

require "rails_helper"

RSpec.describe Operations::ALevelEquivalencies do
  subject(:operation) { described_class.new(repository:, step:) }

  let(:course) { create(:course) }
  let(:repository) { instance_double(DfE::Wizard::Repository::Model, record: course) }
  let(:step) do
    instance_double(
      ALevelSteps::ALevelEquivalencies,
      accept_a_level_equivalency?: accept_a_level_equivalency,
      additional_a_level_equivalencies: additional_a_level_equivalencies,
    )
  end
  let(:accept_a_level_equivalency) { false }
  let(:additional_a_level_equivalencies) { nil }

  describe "#execute" do
    context "when accepting A level equivalencies" do
      let(:accept_a_level_equivalency) { true }
      let(:additional_a_level_equivalencies) { "Some additional info" }

      it "updates course with accept_a_level_equivalency as true" do
        expect { operation.execute }.to change { course.reload.accept_a_level_equivalency }.to(true)
      end

      it "updates course with additional_a_level_equivalencies" do
        expect { operation.execute }.to change { course.reload.additional_a_level_equivalencies }.to("Some additional info")
      end

      it "returns success" do
        expect(operation.execute).to eq({ success: true })
      end
    end

    context "when accepting A level equivalencies without additional info" do
      let(:accept_a_level_equivalency) { true }
      let(:additional_a_level_equivalencies) { "" }

      it "updates course with accept_a_level_equivalency as true" do
        expect { operation.execute }.to change { course.reload.accept_a_level_equivalency }.to(true)
      end

      it "updates course with additional_a_level_equivalencies as empty string" do
        operation.execute
        course.reload
        expect(course.additional_a_level_equivalencies).to eq("")
      end
    end

    context "when not accepting A level equivalencies" do
      let(:accept_a_level_equivalency) { false }
      let(:additional_a_level_equivalencies) { "Some additional info" }

      it "updates course with accept_a_level_equivalency as false" do
        expect { operation.execute }.to change { course.reload.accept_a_level_equivalency }.to(false)
      end

      it "does not update additional_a_level_equivalencies" do
        operation.execute
        course.reload
        expect(course.additional_a_level_equivalencies).to be_nil
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
