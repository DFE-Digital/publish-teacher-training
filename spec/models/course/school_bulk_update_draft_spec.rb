# frozen_string_literal: true

require "rails_helper"

describe Course::SchoolBulkUpdateDraft do
  let(:provider) { create(:provider) }
  let(:user) { create(:user, providers: [provider]) }
  let(:course) { create(:course, provider:) }
  let(:other_course) { create(:course, provider:) }

  def start(course:, school_uuids: [], baseline_uuids: [])
    described_class.start(course:, user:, school_uuids:, baseline_uuids:)
  end

  def uuids(count)
    Array.new(count) { SecureRandom.uuid }
  end

  describe ".start" do
    it "returns a draft with a fresh state key" do
      first = start(course:)
      second = start(course:)

      expect(first.state_key).to be_present
      expect(first.state_key).not_to eq(second.state_key)
    end

    it "persists the selection so a later request can read it back" do
      ticked = uuids(2)
      attached = uuids(1)
      draft = start(course:, school_uuids: ticked, baseline_uuids: attached)

      found = described_class.resolve(course:, state_key: draft.state_key)

      expect(found.school_uuids).to eq(ticked)
      expect(found.baseline_uuids).to eq(attached)
    end

    it "records who started it" do
      expect(start(course:).user).to eq(user)
    end
  end

  describe ".resolve" do
    it "returns nil when the state key is unknown" do
      expect(described_class.resolve(course:, state_key: SecureRandom.uuid)).to be_nil
    end

    it "returns nil when the state key is blank" do
      expect(described_class.resolve(course:, state_key: nil)).to be_nil
      expect(described_class.resolve(course:, state_key: "")).to be_nil
    end

    it "returns nil when the state key is not a uuid at all" do
      expect(described_class.resolve(course:, state_key: "not-a-uuid")).to be_nil
    end

    it "returns nil when the state key belongs to another course" do
      draft = start(course: other_course)

      expect(described_class.resolve(course:, state_key: draft.state_key)).to be_nil
    end

    it "returns nil once the draft has expired" do
      draft = start(course:)

      travel(described_class::EXPIRES_IN + 1.minute) do
        expect(described_class.resolve(course:, state_key: draft.state_key)).to be_nil
      end
    end
  end

  describe "the change it carries" do
    it "reports the schools added and removed against the baseline" do
      a, b, c = uuids(3)
      draft = start(course:, school_uuids: [a, b], baseline_uuids: [b, c])

      expect(draft.added_uuids).to eq([a])
      expect(draft.removed_uuids).to eq([c])
      expect(draft).to be_changed
    end

    it "reports no change when the selection matches the baseline" do
      a, b = uuids(2)
      draft = start(course:, school_uuids: [b, a], baseline_uuids: [a, b])

      expect(draft.added_uuids).to be_empty
      expect(draft.removed_uuids).to be_empty
      expect(draft).not_to be_changed
    end
  end

  describe "#update" do
    it "keeps the selection and records the chosen scope" do
      ticked = uuids(1)
      draft = start(course:, school_uuids: ticked)

      draft.update!(scope: "all")

      found = described_class.resolve(course:, state_key: draft.state_key)
      expect(found.scope).to eq("all")
      expect(found.school_uuids).to eq(ticked)
    end
  end

  describe "#destroy" do
    it "makes the draft unresolvable" do
      draft = start(course:)

      draft.destroy

      expect(described_class.resolve(course:, state_key: draft.state_key)).to be_nil
    end
  end

  describe ".expired" do
    it "is the drafts past their time, for the sweep" do
      stale = start(course:)
      stale.update_column(:expires_at, 1.minute.ago)
      start(course:)

      expect(described_class.expired).to contain_exactly(stale)
    end
  end
end
