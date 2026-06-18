# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolExperienceWizard::Repositories::SchoolExperienceCacheRepository do
  subject(:repository) do
    described_class.new(
      provider_code: "ABC",
      recruitment_cycle_year: 2025,
      course_code: "X123",
      expires_in: 24.hours,
      cache:,
    )
  end

  let(:cache) { ActiveSupport::Cache::MemoryStore.new }

  describe ".cache_key" do
    it "namespaces the key by provider, cycle and course" do
      expect(described_class.cache_key(provider_code: "ABC", recruitment_cycle_year: 2025, course_code: "X123"))
        .to eq("school_experience_wizard_ABC_2025_X123")
    end
  end

  describe "reading and writing" do
    it "stores the wizard answers without touching any course record" do
      repository.write(experience_required: true)

      expect(repository.read[:experience_required]).to be(true)
    end

    it "writes under the namespaced cache key" do
      repository.write(experience_required: true)

      cached = cache.read("school_experience_wizard_ABC_2025_X123")
      expect(cached["experience_required"]).to be(true)
    end

    it "expires the entry after the configured duration" do
      repository.write(experience_required: true)

      Timecop.travel(25.hours) do
        expect(repository.read).to eq({})
      end
    end
  end
end
