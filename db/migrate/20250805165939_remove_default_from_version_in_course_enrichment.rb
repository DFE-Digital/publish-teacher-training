# frozen_string_literal: true

# This migration removes the default value from the version column in course_enrichment table
class RemoveDefaultFromVersionInCourseEnrichment < ActiveRecord::Migration[8.0]
  # This migration removes the default value from the version column in course_enrichment table
  # It ensures that existing records have the correct version set
  # and updates records created after October 1, 2025, to have a version of 2.
  def up
    # Remove the default value for the version column in course_enrichment table
    change_column :course_enrichment, :version, :integer, default: nil, null: true

    # Ensure existing records have the correct version set
    CourseEnrichment.update_all(version: 1)
    # Update existing records to set version to 2 if they were created after October 1, 2025
    CourseEnrichment.where("created_at > ?", Time.new(2025, 10, 1)).update_all(version: 2)
  end

  # This method is used to revert the changes made in the up method.
  def down
    # Revert the changes made in the up method
    change_column :course_enrichment, :version, :integer, default: 1, null: false
  end
end
