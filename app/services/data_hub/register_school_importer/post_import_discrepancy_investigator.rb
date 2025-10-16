module DataHub
  module RegisterSchoolImporter
    class PostImportDiscrepancyInvestigator
      attr_reader :provider, :csv_urns, :db_urns, :gias_urns, :investigation_results

      def initialize(recruitment_cycle:, csv_path:, provider_code:)
        @recruitment_cycle = recruitment_cycle
        @csv_path = csv_path
        @provider_code = provider_code
        @csv_urns = []
        @db_urns = []
        @gias_urns = []
        @investigation_results = {}
        @provider = @recruitment_cycle.providers.find_by(provider_code: @provider_code)
      end

      def call
        extract_all_urns
        perform_analysis

        self
      end

      def print_full_report
        DiscrepancyReportPrinter.new(self).print_full_report
      end

      def export_to_csv(filename = nil)
        filename = generate_filename(filename)
        write_csv_data(filename)
        puts "\nResults exported to: #{filename}" unless Rails.env.test? # rubocop:disable Rails/Output
        filename
      end

    private

      def extract_all_urns
        extract_csv_urns
        extract_db_urns
        extract_gias_urns
      end

      def extract_csv_urns
        CSV.foreach(@csv_path, headers: true) do |row|
          parser = RowParser.new(row)
          next unless parser.provider_code == @provider_code

          @csv_urns.concat(parser.urns) if parser.urns.any?
        end

        @csv_urns = @csv_urns.flatten.uniq.compact
      end

      def extract_db_urns
        return unless provider

        @db_urns = provider.sites
                          .where(added_via: "register_import")
                          .pluck(:urn)
                          .flatten.uniq.compact
      end

      def extract_gias_urns
        all_urns = (@csv_urns + @db_urns).uniq
        @gias_urns = GiasSchool.where(urn: all_urns).pluck(:urn)
      end

      def perform_analysis
        @investigation_results = {
          **raw_counts,
          **comparison_counts,
          **gias_filtered_counts,
          **detailed_arrays,
          **full_arrays,
        }
      end

      def raw_counts
        {
          csv_total: @csv_urns.length,
          db_total: @db_urns.length,
          csv_valid_gias: csv_valid_gias.length,
          db_valid_gias: db_valid_gias.length,
        }
      end

      def comparison_counts
        {
          csv_only_count: csv_only.length,
          db_only_count: db_only.length,
          both_count: both_urns.length,
        }
      end

      def gias_filtered_counts
        {
          missing_valid_urns_count: missing_valid_urns.length,
          invalid_csv_urns_count: invalid_csv_urns.length,
          extra_db_urns_count: extra_db_urns.length,
        }
      end

      def detailed_arrays
        {
          csv_only: csv_only,
          db_only: db_only,
          both_urns: both_urns,
          missing_valid_urns: missing_valid_urns,
          invalid_csv_urns: invalid_csv_urns,
          extra_db_urns: extra_db_urns,
        }
      end

      def full_arrays
        {
          csv_urns: @csv_urns,
          db_urns: @db_urns,
          gias_urns: @gias_urns,
        }
      end

      def csv_valid_gias
        @csv_urns & @gias_urns
      end

      def db_valid_gias
        @db_urns & @gias_urns
      end

      def csv_only
        @csv_urns - @db_urns
      end

      def db_only
        @db_urns - @csv_urns
      end

      def both_urns
        @csv_urns & @db_urns
      end

      def missing_valid_urns
        csv_valid_gias - @db_urns
      end

      def invalid_csv_urns
        @csv_urns - @gias_urns
      end

      def extra_db_urns
        db_only & @gias_urns
      end

      def generate_filename(filename)
        filename || "discrepancy_investigation_#{@provider_code}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
      end

      def write_csv_data(filename)
        CSV.open(filename, "w") do |csv|
          csv << csv_headers
          all_unique_urns.each { |urn| csv << csv_row_for_urn(urn) }
        end
      end

      def csv_headers
        %w[URN Status GIAS_School_Name In_CSV In_Database Valid_GIAS]
      end

      def all_unique_urns
        (@csv_urns + @db_urns).uniq
      end

      def csv_row_for_urn(urn)
        gias_school = GiasSchool.find_by(urn: urn)
        in_csv = @csv_urns.include?(urn)
        in_db = @db_urns.include?(urn)
        valid_gias = !gias_school.nil?

        [urn, determine_status(in_csv, in_db, valid_gias), gias_school&.name, in_csv, in_db, valid_gias]
      end

      def determine_status(in_csv, in_db, valid_gias)
        case [in_csv, in_db, valid_gias]
        when [true, true, true] then "Successfully Imported"
        when [true, false, true] then "Missing from Database"
        when [true, false, false], [true, true, false] then "Invalid GIAS URN"
        when [false, true, true] then "Extra in Database"
        else "Unknown"
        end
      end
    end
  end
end
