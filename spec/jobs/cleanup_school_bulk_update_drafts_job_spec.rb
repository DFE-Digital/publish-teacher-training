# frozen_string_literal: true

require "rails_helper"

RSpec.describe CleanupSchoolBulkUpdateDraftsJob do
  let(:provider) { create(:provider) }
  let(:user) { create(:user, providers: [provider]) }
  let(:course) { create(:course, provider:) }

  def draft
    Course::SchoolBulkUpdateDraft.start(course:, user:, school_uuids: [], baseline_uuids: [])
  end

  it "deletes drafts past their time" do
    stale = draft
    stale.update_column(:expires_at, 1.hour.ago)

    described_class.new.perform

    expect(Course::SchoolBulkUpdateDraft.find_by(id: stale.id)).to be_nil
  end

  it "leaves drafts that can still be applied" do
    live = draft

    described_class.new.perform

    expect(Course::SchoolBulkUpdateDraft.find_by(id: live.id)).to be_present
  end
end
