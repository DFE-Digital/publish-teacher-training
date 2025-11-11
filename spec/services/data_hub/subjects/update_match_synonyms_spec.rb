# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::Subjects::UpdateMatchSynonyms do
  let(:subject_record) do
    find_or_create(
      :secondary_subject,
      :mathematics,
      match_synonyms: %w[math arithmetics],
    )
  end

  describe "#call" do
    it "replaces existing synonyms with new ones" do
      described_class.new(subject: subject_record, synonyms: %w[numeracy maths]).call

      expect(subject_record.reload.match_synonyms).to contain_exactly("numeracy", "maths")
      expect(subject_record.match_synonyms).not_to include("math", "arithmetics")
    end

    it "clears synonyms when given an empty array" do
      described_class.new(subject: subject_record, synonyms: []).call

      expect(subject_record.reload.match_synonyms).to be_empty
    end

    it "removes duplicates from input" do
      described_class.new(subject: subject_record, synonyms: %w[maths maths numeracy]).call

      expect(subject_record.reload.match_synonyms).to contain_exactly("maths", "numeracy")
    end

    it "removes blank values from input" do
      described_class.new(subject: subject_record, synonyms: ["maths", "", nil, "  "]).call

      expect(subject_record.reload.match_synonyms).to eq(%w[maths])
    end

    it "accepts a single synonym as a string" do
      described_class.new(subject: subject_record, synonyms: "calc").call

      expect(subject_record.reload.match_synonyms).to eq(%w[calc])
    end

    it "accepts synonyms as an array" do
      described_class.new(subject: subject_record, synonyms: %w[calc numbers]).call

      expect(subject_record.reload.match_synonyms).to contain_exactly("calc", "numbers")
    end

    it "persists changes to the database" do
      described_class.new(subject: subject_record, synonyms: "stats").call

      reloaded = Subject.find(subject_record.id)
      expect(reloaded.match_synonyms).to eq(%w[stats])
    end

    it "handles nil input" do
      described_class.new(subject: subject_record, synonyms: nil).call

      expect(subject_record.reload.match_synonyms).to be_empty
    end

    it "maintains order of input synonyms" do
      described_class.new(subject: subject_record, synonyms: %w[zulu alpha bravo]).call

      expect(subject_record.reload.match_synonyms).to eq(%w[zulu alpha bravo])
    end
  end

  describe "cache expiration" do
    let(:subjects_cache) { instance_double(SubjectsCache) }

    it "expires the subjects cache when synonyms are changed" do
      expect(subjects_cache).to receive(:expire_cache)

      described_class.new(subject: subject_record, synonyms: %w[maths calc], subjects_cache: subjects_cache).call
    end

    it "expires cache when clearing synonyms" do
      expect(subjects_cache).to receive(:expire_cache)

      described_class.new(subject: subject_record, synonyms: [], subjects_cache: subjects_cache).call
    end

    it "uses SubjectsCache by default when not provided" do
      cache_instance = instance_double(SubjectsCache)
      allow(SubjectsCache).to receive(:new).and_return(cache_instance)
      allow(cache_instance).to receive(:expire_cache)

      described_class.new(subject: subject_record, synonyms: "maths").call

      expect(cache_instance).to have_received(:expire_cache)
    end
  end
end
