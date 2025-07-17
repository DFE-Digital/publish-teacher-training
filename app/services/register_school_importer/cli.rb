module RegisterSchoolImporter
  class CLI
    attr_reader :csv_path, :year

    def initialize(env: ENV)
      @csv_path = env["CSV_PATH"]
      @year = env["YEAR"]
    end

    def validate!
      if csv_path.blank? || year.blank?
        Rails.logger.info <<~USAGE
          ERROR: Missing required environment variables.

          Usage:
            CSV_PATH=path/to/register.csv YEAR=2025 bin/rails register_schools:import
          Example:
            CSV_PATH=/home/user/register_2025.csv YEAR=2025 bin/rails register_schools:import
        USAGE

        raise
      end
    end

    def recruitment_cycle
      rc = RecruitmentCycle.find_by(year:)

      unless rc
        Rails.logger.info "ERROR: RecruitmentCycle with year=#{year} not found."
        raise
      end

      rc
    end
  end
end
