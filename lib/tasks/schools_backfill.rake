# frozen_string_literal: true

namespace :schools_backfill do
  desc "Backfill provider_school and course_school from legacy site data"
  task :run, [:recruitment_cycle_years] => :environment do |_task, args|
    recruitment_cycle_years = [args[:recruitment_cycle_years], *args.extras].compact
    recruitment_cycle_years = RecruitmentCycle.pluck(:year) if recruitment_cycle_years.empty?

    summary = DataHub::SchoolsBackfill::Executor.new(recruitment_cycle_years:).execute
    pp summary.short_summary
    pp summary.full_summary
  end
end
