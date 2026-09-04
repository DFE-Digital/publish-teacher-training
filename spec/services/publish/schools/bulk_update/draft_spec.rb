# frozen_string_literal: true

require "rails_helper"

describe Publish::Schools::BulkUpdate::Draft do
  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }
  let(:other_course) { create(:course, provider:) }

  describe ".create" do
    it "returns a draft with a fresh state key" do
      draft = described_class.create(course:, school_uuids: %w[a b], baseline_uuids: %w[b])

      expect(draft.state_key).to be_present
      expect(described_class.create(course:, school_uuids: [], baseline_uuids: []).state_key)
        .not_to eq(draft.state_key)
    end

    it "persists the selection so a later request can read it back" do
      draft = described_class.create(course:, school_uuids: %w[a b], baseline_uuids: %w[b])

      found = described_class.find(course:, state_key: draft.state_key)

      expect(found.school_uuids).to eq(%w[a b])
      expect(found.baseline_uuids).to eq(%w[b])
    end
  end

  describe ".find" do
    it "returns nil when the state key is unknown" do
      expect(described_class.find(course:, state_key: SecureRandom.uuid)).to be_nil
    end

    it "returns nil when the state key belongs to another course" do
      draft = described_class.create(course: other_course, school_uuids: %w[a], baseline_uuids: [])

      expect(described_class.find(course:, state_key: draft.state_key)).to be_nil
    end

    it "returns nil once the draft has expired" do
      draft = described_class.create(course:, school_uuids: %w[a], baseline_uuids: [])

      travel(described_class::EXPIRES_IN + 1.minute) do
        expect(described_class.find(course:, state_key: draft.state_key)).to be_nil
      end
    end
  end

  describe "the change it carries" do
    it "reports the schools added and removed against the baseline" do
      draft = described_class.create(course:, school_uuids: %w[a b], baseline_uuids: %w[b c])

      expect(draft.added_uuids).to eq(%w[a])
      expect(draft.removed_uuids).to eq(%w[c])
      expect(draft).to be_changed
    end

    it "reports no change when the selection matches the baseline" do
      draft = described_class.create(course:, school_uuids: %w[b a], baseline_uuids: %w[a b])

      expect(draft.added_uuids).to be_empty
      expect(draft.removed_uuids).to be_empty
      expect(draft).not_to be_changed
    end
  end

  describe "#update" do
    it "keeps the selection and records the chosen scope" do
      draft = described_class.create(course:, school_uuids: %w[a], baseline_uuids: [])

      draft.update(scope: "all")

      found = described_class.find(course:, state_key: draft.state_key)
      expect(found.scope).to eq("all")
      expect(found.school_uuids).to eq(%w[a])
    end
  end

  describe "#delete" do
    it "makes the draft unfindable" do
      draft = described_class.create(course:, school_uuids: %w[a], baseline_uuids: [])

      draft.delete

      expect(described_class.find(course:, state_key: draft.state_key)).to be_nil
    end
  end
end
