# frozen_string_literal: true

# This migration adds a version column to the course_enrichments table.
class AddVersionForCourseEnrichment < ActiveRecord::Migration[8.0]
  # This migration adds a version column to the course_enrichments table.
  # It sets the default version to 1 for existing records and updates
  # records created after October 1, 2025, to have a version of 2.
  def up
    add_column :course_enrichment, :version, :integer, default: 1, null: false

    # Ensure existing records have the initial version set correctly
    CourseEnrichment.where("created_at > ?", Time.zone.local(2025, 10, 1)).update_all(version: 2)
  end

  # This method is used to remove the version column if needed.
  # It is not strictly necessary but can be useful for rollback purposes.
  # If you want to keep the versioning, you can remove this method.
  def down
    remove_column :course_enrichment, :version
  end
end
