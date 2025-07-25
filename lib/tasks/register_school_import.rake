namespace :register_schools do
  desc "Real import: Process register of placement schools from CSV (saves data)"
  task import: :environment do
    cli = DataHub::RegisterSchoolImporter::Cli.new
    cli.validate!
    recruitment_cycle = cli.recruitment_cycle

    puts "Starting REAL RegisterSchools import"
    puts "CSV Path: #{cli.csv_path}"
    puts "Recruitment Cycle: #{recruitment_cycle.year}"

    orchestrator = DataHub::RegisterSchoolImporter::ImportOrchestrator.new(
      recruitment_cycle: recruitment_cycle,
      csv_path: cli.csv_path,
      school_creator_class: DataHub::RegisterSchoolImporter::SchoolCreator,
    )

    import_record = orchestrator.run!

    puts "Import completed successfully with ID=#{import_record.id}"
    puts "Summary: #{import_record.short_summary.to_json}"
  rescue StandardError => e
    puts "Import failed: #{e.message}"
    puts e.backtrace.join("\n")
    exit 1
  end

  desc "Dry-run import: Simulate register of placement schools import (no data changed)"
  task dry_run: :environment do
    cli = DataHub::RegisterSchoolImporter::Cli.new
    cli.validate!
    recruitment_cycle = cli.recruitment_cycle

    puts "Starting DRY RUN RegisterSchools import"
    puts "CSV Path: #{cli.csv_path}"
    puts "Recruitment Cycle: #{recruitment_cycle.year}"

    summary = DataHub::RegisterSchoolImporter::Importer.new(
      recruitment_cycle:,
      csv_path: cli.csv_path,
      school_creator_class: DataHub::RegisterSchoolImporter::SchoolDryRunCreator,
    ).call

    puts "Summary: #{summary.meta.to_json}"
  rescue StandardError => e
    puts "Dry run import failed: #{e.message}"
    puts e.backtrace.join("\n")
    exit 1
  end
end
