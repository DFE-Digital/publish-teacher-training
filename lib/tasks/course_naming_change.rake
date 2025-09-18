# frozen_string_literal: true

namespace :course_naming do
  desc "Dry run: report course name replacements without saving changes"
  task :dry_run, %i[csv_path year absolute_threshold percentage_threshold] => :environment do |_t, args|
    csv_path = args[:csv_path] || ENV["CSV_PATH"]
    raise "CSV path required (pass as first argument or CSV_PATH env var)" if csv_path.blank?

    year = args[:year] || ENV["YEAR"]
    absolute_threshold = parse_absolute_threshold(args[:absolute_threshold] || ENV["ABSOLUTE_THRESHOLD"])
    percentage_threshold = parse_percentage_threshold(args[:percentage_threshold] || ENV["PERCENTAGE_THRESHOLD"])

    recruitment_cycle = fetch_recruitment_cycle(year)

    DataHub::CourseNamingChange::Runner.new(
      csv_path:,
      recruitment_cycle:,
      dry_run: true,
      output: $stdout,
      absolute_warning_threshold: absolute_threshold,
      percentage_warning_threshold: percentage_threshold,
    ).call
  end

  desc "Apply course name replacements from CSV"
  task :apply, %i[csv_path year absolute_threshold percentage_threshold] => :environment do |_t, args|
    csv_path = args[:csv_path] || ENV["CSV_PATH"]
    raise "CSV path required (pass as first argument or CSV_PATH env var)" if csv_path.blank?

    year = args[:year] || ENV["YEAR"]
    absolute_threshold = parse_absolute_threshold(args[:absolute_threshold] || ENV["ABSOLUTE_THRESHOLD"])
    percentage_threshold = parse_percentage_threshold(args[:percentage_threshold] || ENV["PERCENTAGE_THRESHOLD"])
    recruitment_cycle = fetch_recruitment_cycle(year)

    DataHub::CourseNamingChange::Runner.new(
      csv_path:,
      recruitment_cycle:,
      dry_run: false,
      output: $stdout,
      absolute_warning_threshold: absolute_threshold,
      percentage_warning_threshold: percentage_threshold,
    ).call
  end
end

namespace :course_naming do
  def fetch_recruitment_cycle(year)
    return RecruitmentCycle.find_by!(year:) if year.present?

    RecruitmentCycle.current
  end

  def parse_absolute_threshold(value)
    return DataHub::CourseNamingChange::Runner::DEFAULT_ABSOLUTE_WARNING_THRESHOLD if value.blank?

    Integer(value)
  rescue ArgumentError
    raise ArgumentError, "Invalid ABSOLUTE_THRESHOLD: '#{value}'"
  end

  def parse_percentage_threshold(value)
    return DataHub::CourseNamingChange::Runner::DEFAULT_PERCENTAGE_WARNING_THRESHOLD if value.blank?

    Float(value)
  rescue ArgumentError
    raise ArgumentError, "Invalid PERCENTAGE_THRESHOLD: '#{value}'"
  end
end
