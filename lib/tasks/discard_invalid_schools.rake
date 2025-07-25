namespace :discard_invalid_schools do
  desc "Discard invalid school sites from providers (REAL run)"
  task run: :environment do
    year = ENV["YEAR"]

    if year.blank?
      puts "ERROR: You must provide the YEAR environment variable."
      puts "    Example: YEAR=2025 rake discard_invalid_schools:run"
      exit(1)
    end

    puts "Starting REAL discard for recruitment cycle year #{year}..."

    DataHub::DiscardInvalidSchools::Executor.new(
      year:,
      discarder_class: DataHub::DiscardInvalidSchools::SiteDiscarder,
    ).execute

    puts "REAL discard completed."
  rescue StandardError => e
    puts "ERROR during real discard: #{e.message}"
    puts e.backtrace
    raise e
  end

  desc "Simulate discarding invalid school sites without changes (DRY RUN)"
  task dry_run: :environment do
    year = ENV["YEAR"]

    if year.blank?
      puts "ERROR: You must provide the YEAR environment variable."
      puts "    Example: YEAR=2025 rake discard_invalid_schools:dry_run"
      exit(1)
    end

    puts "Starting DRY RUN discard simulation for recruitment cycle year #{year}..."

    DataHub::DiscardInvalidSchools::Executor.new(
      year:,
      discarder_class: DataHub::DiscardInvalidSchools::DryRunSiteDiscarder,
    ).execute

    puts "DRY RUN discard simulation completed."
  rescue StandardError => e
    puts "ERROR during dry run discard simulation: #{e.message}"
    puts e.backtrace
    raise e
  end
end
