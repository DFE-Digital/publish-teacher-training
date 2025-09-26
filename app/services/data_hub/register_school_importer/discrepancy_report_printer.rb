# rubocop:disable Rails/Output
module DataHub
  module RegisterSchoolImporter
    class DiscrepancyReportPrinter
      def initialize(investigator)
        @investigator = investigator
        @results = investigator.investigation_results
      end

      def print_full_report
        print_header
        print_summary_stats
        print_comparisons
        print_detailed_listings
      end

    private

      def print_header
        puts "=" * 80
        puts "POST-IMPORT DISCREPANCY INVESTIGATION REPORT"
        puts "=" * 80
        puts "Provider Code: #{@investigator.provider&.provider_code}"
        puts "Investigation Date: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
        puts ""
      end

      def print_summary_stats
        puts "SUMMARY STATISTICS"
        puts "-" * 40
        puts "CSV URNs found: #{@results[:csv_total]}"
        puts "Database URNs found: #{@results[:db_total]}"
        puts "Valid GIAS URNs (CSV): #{@results[:csv_valid_gias]}"
        puts "Valid GIAS URNs (DB): #{@results[:db_valid_gias]}"
        puts ""
      end

      def print_comparisons
        print_csv_vs_db_comparison
        print_gias_filtered_analysis
      end

      def print_csv_vs_db_comparison
        puts "CSV vs DATABASE COMPARISON"
        puts "-" * 40
        puts "URNs in CSV but NOT in Database: #{@results[:csv_only_count]}"
        puts "URNs in Database but NOT in CSV: #{@results[:db_only_count]}"
        puts "URNs in BOTH CSV and Database: #{@results[:both_count]}"
        puts ""
      end

      def print_gias_filtered_analysis
        puts "GIAS-FILTERED ANALYSIS (Valid Schools Only)"
        puts "-" * 40
        puts "Valid CSV URNs not imported to DB: #{@results[:missing_valid_urns_count]}"
        puts "Invalid CSV URNs (no GIAS record): #{@results[:invalid_csv_urns_count]}"
        puts "Extra DB URNs not in CSV: #{@results[:extra_db_urns_count]}"
        puts ""
      end

      def print_detailed_listings
        puts "DETAILED LISTINGS"
        puts "-" * 40

        print_missing_valid_urns
        print_invalid_csv_urns
        print_extra_db_urns
        print_successfully_imported_urns
      end

      def print_missing_valid_urns
        return unless @results[:missing_valid_urns].any?

        puts "\n📋 VALID CSV URNs NOT IMPORTED (#{@results[:missing_valid_urns_count]}):"
        print_urn_list(@results[:missing_valid_urns], with_names: true)
      end

      def print_invalid_csv_urns
        return unless @results[:invalid_csv_urns].any?

        puts "\n❌ INVALID CSV URNs (No GIAS record) (#{@results[:invalid_csv_urns_count]}):"
        print_urn_list(@results[:invalid_csv_urns], with_names: false)
      end

      def print_extra_db_urns
        return unless @results[:extra_db_urns].any?

        puts "\n➕ EXTRA DATABASE URNs (Not in CSV) (#{@results[:extra_db_urns_count]}):"
        print_urn_list(@results[:extra_db_urns], with_names: true)
      end

      def print_successfully_imported_urns
        return unless @results[:both_urns].any?

        puts "\n✅ SUCCESSFULLY IMPORTED URNs (In both CSV and DB) (#{@results[:both_count]}):"
        print_urn_list(@results[:both_urns], with_names: true)
      end

      def print_urn_list(urns, with_names: true)
        urns.each_with_index do |urn, index|
          if with_names
            gias_school = GiasSchool.find_by(urn: urn)
            puts "  #{index + 1}. #{urn} - #{gias_school&.name}"
          else
            puts "  #{index + 1}. #{urn}"
          end
        end
      end
    end
  end
end
# rubocop:enable Rails/Output
