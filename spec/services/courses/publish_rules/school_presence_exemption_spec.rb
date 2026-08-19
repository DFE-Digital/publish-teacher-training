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

    it "applies to a fee-paying course support has allowed to publish without schools" do
      expect(described_class.applies?(course_with(funding: :fee, allowed: true))).to be(true)
    end

    it "does not apply to a salaried course support has not allowed" do
      expect(described_class.applies?(course_with(funding: :salary, allowed: false))).to be(false)
    end

    it "does not apply to an apprenticeship course support has not allowed" do
      expect(described_class.applies?(course_with(funding: :apprenticeship, allowed: false))).to be(false)
    end
  end

  describe ".falling_back_to_provider_schools" do
    let(:provider) { create(:provider) }

    it "returns exempt courses with no schools of their own" do
      salaried = create(:course, provider:, publish_without_schools_allowed: true)
      apprenticeship = create(:course, :with_apprenticeship, provider:, publish_without_schools_allowed: true)
      fee = create(:course, :fee, provider:, publish_without_schools_allowed: true)

      expect(described_class.falling_back_to_provider_schools(provider)).to contain_exactly(salaried, apprenticeship, fee)
    end

    it "excludes an exempt course that has its own schools" do
      create(:course, :with_2_schools, provider:, publish_without_schools_allowed: true)

      expect(described_class.falling_back_to_provider_schools(provider)).to be_empty
    end

    it "excludes a course support has not allowed to publish without schools" do
      create(:course, provider:, publish_without_schools_allowed: false)

      expect(described_class.falling_back_to_provider_schools(provider)).to be_empty
    end

    it "excludes another provider's courses" do
      create(:course, publish_without_schools_allowed: true)

      expect(described_class.falling_back_to_provider_schools(provider)).to be_empty
    end
  end
end
