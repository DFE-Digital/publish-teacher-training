class AddMissingIndexesForFindQueries < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :course_site, %i[course_id status publish],
              where: "status = 'R' AND publish = 'Y'",
              name: "idx_course_site_published_filtered",
              algorithm: :concurrently

    add_index :course, %i[provider_id application_status id],
              where: "discarded_at IS NULL",
              name: "idx_course_provider_active",
              algorithm: :concurrently

    add_index :course, %i[name provider_id course_code],
              where: "discarded_at IS NULL",
              name: "idx_course_ordering_optimized",
              algorithm: :concurrently

    add_index :provider, %i[recruitment_cycle_id discarded_at id],
              where: "discarded_at IS NULL",
              name: "idx_provider_cycle_discarded",
              algorithm: :concurrently
  end
end
