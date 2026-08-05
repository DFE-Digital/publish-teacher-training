# frozen_string_literal: true

require "rails_helper"

describe Courses::PublishRules::SchoolPresenceExemption do
  describe ".applies?" do
    def course_with(funding:, allowed:)
      build_stubbed(:course, funding, publish_without_schools_allowed: allowed)
    end

    it "applies to a salaried course support has allowed to publish without schools" do
      expect(described_class.applies?(course_with(funding: :salary, allowed: true))).to be(true)
    end

    it "applies to an apprenticeship course support has allowed to publish without schools" do
      expect(described_class.applies?(course_with(funding: :apprenticeship, allowed: true))).to be(true)
    end

    it "does not apply to a fee-paying course, even when allowed" do
      expect(described_class.applies?(course_with(funding: :fee, allowed: true))).to be(false)
    end

    it "does not apply to a salaried course support has not allowed" do
      expect(described_class.applies?(course_with(funding: :salary, allowed: false))).to be(false)
    end

    it "does not apply to an apprenticeship course support has not allowed" do
      expect(described_class.applies?(course_with(funding: :apprenticeship, allowed: false))).to be(false)
    end
  end
end
