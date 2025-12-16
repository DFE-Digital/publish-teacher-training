class AddIndexOnLatestPublishedEnrichment < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :course_enrichment,
              %i[course_id last_published_timestamp_utc],
              order: { last_published_timestamp_utc: :desc },
              where: "status = 1",
              name: "ix_enrichment_latest_published",
              algorithm: :concurrently
  end
end
