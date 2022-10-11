# frozen_string_literal: true

class FixIncorrectDraftFindableCourses < ActiveRecord::Migration[7.0]
  def up
    Course.joins(:site_statuses, :enrichments).where(enrichments: { status: %w[draft] }, site_statuses: { status: "running" }).find_each do |course|
      course.site_statuses.update_all(publish: :unpublished, status: :new_status)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
