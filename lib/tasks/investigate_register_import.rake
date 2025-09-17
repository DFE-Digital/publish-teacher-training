namespace :register_import do
  desc "Investigate post-import discrepancies for a provider. Usage: rake register_import:discrepancy[provider_code,csv_path,recruitment_cycle_year]"
  task :discrepancy, %i[provider_code csv_path recruitment_cycle_year] => :environment do |_t, args|
    unless args.provider_code && args.csv_path
      puts "Error: provider_code and csv_path are required."
      puts "Usage: rake register_import:discrepancy[provider_code,csv_path,recruitment_cycle_year]"
      exit 1
    end

    recruitment_cycle = RecruitmentCycle.find_by(year: args.recruitment_cycle_year)

    unless recruitment_cycle
      puts "Error: RecruitmentCycle not found. Please specify a valid recruitment_cycle_year."
      exit 1
    end

    csv_full_path = File.expand_path(args.csv_path)

    unless File.exist?(csv_full_path)
      puts "Error: CSV file not found at #{csv_full_path}"
      exit 1
    end

    investigator = DataHub::RegisterSchoolImporter::PostImportDiscrepancyInvestigator.new(
      recruitment_cycle: recruitment_cycle,
      csv_path: csv_full_path.to_s,
      provider_code: args.provider_code,
    )

    puts "Starting investigation for provider '#{args.provider_code}' with CSV at #{csv_full_path}..."
    investigator.call
    investigator.print_full_report

    export_path = investigator.export_to_csv(
      Rails.root.join("tmp", "discrepancy_report_#{args.provider_code}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"),
    )
    puts "Investigation report exported to: #{export_path}"
  end
end
