# frozen_string_literal: true

class FixVacStatusOnPublishedCourses < ActiveRecord::Migration[7.0]
  def up
    Course.joins(:site_statuses, :enrichments, provider: :recruitment_cycle).where(
      provider: { recruitment_cycle: { year: "2023" } },
      enrichments: { status: %w[published] },
      study_mode: :full_time_or_part_time,
      site_statuses: { vac_status: %w[part_time_vacancies full_time_vacancies] },
    ).find_each do |course|
      next unless course.is_published?

      course.site_statuses.update_all(vac_status: :both_full_time_and_part_time_vacancies)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
