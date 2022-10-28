# frozen_string_literal: true

class FixIncorrectWithdrawnFindableCourses < ActiveRecord::Migration[7.0]
  def up
    Course.joins(:site_statuses, :enrichments, provider: :recruitment_cycle).where(provider: { recruitment_cycle: { year: "2023" } }, enrichments: { status: %w[withdrawn] }, site_statuses: { status: "running" }).find_each do |course|
      next if course.is_published?

      course.site_statuses.update_all(vac_status: :no_vacancies, publish: :unpublished, status: :suspended)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
