# frozen_string_literal: true

class DeleteSubsequentDraftEnrichments < ActiveRecord::Migration[8.1]
  # Removes draft enrichments that sit on top of previously published courses
  # (the old "unpublished changes" state). Find continues to show the last
  # published enrichment. Does not change application_status.
  # Initial drafts (never published) are left untouched.
  def up
    CourseEnrichment
      .where(status: CourseEnrichment.statuses[:draft])
      .where.not(last_published_timestamp_utc: nil)
      .in_batches(of: 1_000, &:delete_all)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
