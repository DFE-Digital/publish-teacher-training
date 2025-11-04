require "rails_helper"

RSpec.describe DataHub::Subjects::AddMatchSynonyms do
  let(:subject_record) do
    find_or_create(
      :secondary_subject,
      :mathematics,
      match_synonyms: %w[math arithmetics],
    )
  end

  describe "#call" do
    it "adds a new synonym to match_synonyms" do
      described_class.new(subject: subject_record, synonyms: "numeracy").call

      expect(subject_record.reload.match_synonyms).to include("numeracy")
      expect(subject_record.match_synonyms).to include("math", "arithmetics")
    end

    it "adds multiple synonyms at once" do
      described_class.new(subject: subject_record, synonyms: %w[numeracy maths]).call

      expect(subject_record.reload.match_synonyms).to include("numeracy", "maths")
    end

    it "does not add duplicate synonyms" do
      described_class.new(subject: subject_record, synonyms: "math").call

      expect(subject_record.reload.match_synonyms.count("math")).to eq(1)
    end

    it "preserves existing synonyms" do
      original_count = subject_record.match_synonyms.length
      described_class.new(subject: subject_record, synonyms: "maths").call

      expect(subject_record.reload.match_synonyms.length).to be > original_count
      expect(subject_record.match_synonyms).to include("math", "arithmetics", "maths")
    end

    it "removes blank values from input" do
      described_class.new(subject: subject_record, synonyms: ["maths", "", nil, "  "]).call

      expect(subject_record.reload.match_synonyms).to include("maths")
      expect(subject_record.match_synonyms).not_to include("", nil)
    end

    it "returns early if no valid synonyms provided" do
      expect(subject_record).not_to receive(:update!)

      described_class.new(subject: subject_record, synonyms: ["", nil]).call
    end

    it "accepts a single synonym as a string" do
      described_class.new(subject: subject_record, synonyms: "calc").call

      expect(subject_record.reload.match_synonyms).to include("calc")
    end

    it "accepts synonyms as an array" do
      described_class.new(subject: subject_record, synonyms: %w[calc numbers]).call

      expect(subject_record.reload.match_synonyms).to include("calc", "numbers")
    end

    it "persists changes to the database" do
      described_class.new(subject: subject_record, synonyms: "stats").call

      reloaded = Subject.find(subject_record.id)
      expect(reloaded.match_synonyms).to include("stats")
    end

    it "maintains uniqueness across existing and new synonyms" do
      subject_record.update!(match_synonyms: %w[math maths])
      described_class.new(subject: subject_record, synonyms: %w[math numeracy]).call

      expect(subject_record.reload.match_synonyms.count("math")).to eq(1)
      expect(subject_record.match_synonyms).to include("maths", "numeracy")
    end
  end

  describe "cache expiration" do
    let(:subjects_cache) { instance_double(SubjectsCache) }

    it "expires the subjects cache after adding synonyms" do
      expect(subjects_cache).to receive(:expire_cache)

      described_class.new(subject: subject_record, synonyms: "maths", subjects_cache: subjects_cache).call
    end

    it "does not expire cache if no synonyms were added" do
      expect(subjects_cache).not_to receive(:expire_cache)

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
