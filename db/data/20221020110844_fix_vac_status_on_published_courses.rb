# frozen_string_literal: true

class FixVacStatusOnPublishedCourses < ActiveRecord::Migration[7.0]
  def up
    Course.joins(:site_statuses, :enrichments, provider: :recruitment_cycle).where(
      provider: { recruitment_cycle: { year: '2023' } },
      enrichments: { status: %w[published] },
      study_mode: :full_time_or_part_time
    ).find_each do |course|
      next unless course.is_published?
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
