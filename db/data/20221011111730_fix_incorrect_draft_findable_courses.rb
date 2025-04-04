# frozen_string_literal: true

class FixIncorrectDraftFindableCourses < ActiveRecord::Migration[7.0]
  VAC_MAPPING = {
    full_time_or_part_time: :both_full_time_and_part_time_vacancies,
    part_time: :part_time_vacancies,
    full_time: :full_time_vacancies,
  }.freeze

  def up
    Course.joins(:site_statuses, :enrichments, provider: :recruitment_cycle).where(provider: { recruitment_cycle: { year: "2023" } }, enrichments: { status: %w[draft rolled_over] }, site_statuses: { status: "running" }).find_each do |course|
      next if course.is_published?

      course.site_statuses.update_all(publish: :unpublished, status: :new_status, vac_status: VAC_MAPPING[course.study_mode.to_sym] || :no_vacancies)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
