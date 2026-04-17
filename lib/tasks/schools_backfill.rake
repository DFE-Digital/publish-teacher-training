# frozen_string_literal: true

namespace :schools_backfill do
  desc "Backfill provider_school and course_school from legacy site data"
  task run: :environment do
    summary = DataHub::SchoolsBackfill::Executor.new.execute
    pp summary.short_summary
    pp summary.full_summary
  end
end
