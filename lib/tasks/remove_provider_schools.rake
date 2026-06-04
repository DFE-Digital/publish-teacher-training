require "csv"

namespace :remove_provider_schools do
  usage = "PROVIDER_CODE=XYZ YEAR=2025 KEEP_CSV=/path/to/keep.csv"

  desc "Remove (soft discard) a provider's schools except the URNs to keep (REAL run)"
  task run: :environment do
    missing = %w[PROVIDER_CODE YEAR KEEP_CSV].reject { |var| ENV[var].present? }
    if missing.any?
      puts "ERROR: You must provide the following environment variables: #{missing.join(', ')}."
      puts "    Example: #{usage} rake remove_provider_schools:run"
      exit(1)
    end

    keep_urns = CSV.read(ENV["KEEP_CSV"], headers: true).map { |row| row["URN"].to_s.strip }.reject(&:blank?)
    puts "Starting REAL removal for provider #{ENV['PROVIDER_CODE']} (year #{ENV['YEAR']}), keeping #{keep_urns.size} URNs..."

    DataHub::RemoveProviderSchools::Executor.new(
      provider_code: ENV["PROVIDER_CODE"],
      keep_urns:,
      year: ENV["YEAR"],
      discarder_class: DataHub::RemoveProviderSchools::SiteDiscarder,
    ).execute

    pp DataHub::RemoveProviderSchoolsProcessSummary.last.short_summary
    puts "REAL removal completed."
  rescue StandardError => e
    puts "ERROR during real removal: #{e.message}"
    puts e.backtrace
    raise e
  end

  desc "Simulate removing a provider's schools without changes (DRY RUN)"
  task dry_run: :environment do
    missing = %w[PROVIDER_CODE YEAR KEEP_CSV].reject { |var| ENV[var].present? }
    if missing.any?
      puts "ERROR: You must provide the following environment variables: #{missing.join(', ')}."
      puts "    Example: #{usage} rake remove_provider_schools:dry_run"
      exit(1)
    end

    keep_urns = CSV.read(ENV["KEEP_CSV"], headers: true).map { |row| row["URN"].to_s.strip }.reject(&:blank?)
    puts "Starting DRY RUN removal simulation for provider #{ENV['PROVIDER_CODE']} (year #{ENV['YEAR']}), keeping #{keep_urns.size} URNs..."

    DataHub::RemoveProviderSchools::Executor.new(
      provider_code: ENV["PROVIDER_CODE"],
      keep_urns:,
      year: ENV["YEAR"],
      discarder_class: DataHub::RemoveProviderSchools::DryRunSiteDiscarder,
    ).execute

    pp DataHub::RemoveProviderSchoolsProcessSummary.last.short_summary
    puts "DRY RUN removal simulation completed."
  rescue StandardError => e
    puts "ERROR during dry run removal simulation: #{e.message}"
    puts e.backtrace
    raise e
  end
end
