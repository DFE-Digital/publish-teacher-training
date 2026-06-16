# frozen_string_literal: true

require "rails_helper"

describe Courses::PublishRules::SchoolPresenceExemption do
  describe ".applies?" do
    def course_with(funding:, allowed:)
      build_stubbed(:course, funding, publish_without_schools_allowed: allowed)
    end

    context "when the new school model flag is on" do
      before { allow(FeatureFlag).to receive(:active?).with(:course_publishing_uses_new_school_model).and_return(true) }

      it "applies to a salaried course with the flag enabled" do
        expect(described_class.applies?(course_with(funding: :salary, allowed: true))).to be(true)
      end

      it "applies to an apprenticeship course with the flag enabled" do
        expect(described_class.applies?(course_with(funding: :apprenticeship, allowed: true))).to be(true)
      end

      it "does not apply to a fee-paying course even with the flag enabled" do
        expect(described_class.applies?(course_with(funding: :fee, allowed: true))).to be(false)
      end

      it "does not apply to a salaried course without the flag enabled" do
        expect(described_class.applies?(course_with(funding: :salary, allowed: false))).to be(false)
      end

      it "does not apply to an apprenticeship course without the flag enabled" do
        expect(described_class.applies?(course_with(funding: :apprenticeship, allowed: false))).to be(false)
      end
    end

    context "when the new school model flag is off" do
      before { allow(FeatureFlag).to receive(:active?).with(:course_publishing_uses_new_school_model).and_return(false) }

      it "never applies, even for a salaried course with the flag enabled" do
        expect(described_class.applies?(course_with(funding: :salary, allowed: true))).to be(false)
      end
    end
  end
end
