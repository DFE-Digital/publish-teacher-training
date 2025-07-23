module DataHub
  module RegisterSchoolImporter
    class CLI
      attr_reader :csv_path, :year

      def initialize(environment: ENV)
        @csv_path = environment["CSV_PATH"]
        @year = environment["YEAR"]
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

          raise ArgumentError, "CSV_PATH and YEAR must be provided"
        end
      end

      def recruitment_cycle
        recruitment_cycle = RecruitmentCycle.find_by(year: year)

        unless recruitment_cycle
          Rails.logger.info "ERROR: RecruitmentCycle with year=#{year} not found."
          raise ActiveRecord::RecordNotFound, "RecruitmentCycle for year #{year} not found"
        end

        recruitment_cycle
      end
    end
  end
end
