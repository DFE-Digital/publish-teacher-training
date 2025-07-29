namespace :update_sites_from_gias do
  desc "Update sites from GIAS for a recruitment cycle (real run). Usage: rake data_hub:update_sites_from_gias:run YEAR=2025"
  task :run, [:year] => :environment do |_t, args|
    year = args[:year] || ENV["YEAR"]
    raise "YEAR argument (or env) required, e.g. YEAR=2025" if year.blank?

    recruitment_cycle = RecruitmentCycle.find_by!(year: year)
    puts "[DataHub] Updating sites from GIAS for cycle #{year} (REAL RUN)"
    summary = DataHub::UpdateSitesFromGias::Executor.new(recruitment_cycle:).execute
    puts "[DataHub] Complete. Summary:"
    pp summary.short_summary
  end

  desc "Dry run: Preview updates to sites from GIAS for a recruitment cycle (no DB changes). Usage: rake data_hub:update_sites_from_gias:dry_run YEAR=2025"
  task :dry_run, [:year] => :environment do |_t, args|
    year = args[:year] || ENV["YEAR"]
    raise "YEAR argument (or env) required, e.g. YEAR=2025" if year.blank?

    recruitment_cycle = RecruitmentCycle.find_by!(year: year)
    puts "[DataHub] DRY RUN: Showing site updates from GIAS for cycle #{year}"
    summary = DataHub::UpdateSitesFromGias::Executor.new(
      recruitment_cycle:,
      updater_class: DataHub::UpdateSitesFromGias::DryRunSiteUpdater,
    ).execute
    puts "[DataHub] Dry-run complete. Summary:"
    pp summary.short_summary
  end
end
