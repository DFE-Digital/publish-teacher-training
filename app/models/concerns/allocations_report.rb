module AllocationsReport
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    class << self
      def include_allocations_report_data
        all.includes(:provider,
                     :subjects,
                     provider: { organisations: :nctl_organisations })
      end

      # Outputs an allocations XLSX with a randomly generated suffix to `public/`.
      # The first argument is an optional prefix for the filename to make it
      # easier to differentiate among ~200 other similar XLSX files. Defaults to
      # the provider.provider_code.
      # The filename will have a UUID prefix so that it can be hosted
      # and linked to from an Azure bucket, but that the names can't be
      # simply guessed.
      # Example usage:
      #    $ bin/rails c
      #    > Course.save_xlsx(Course.first(20))
      def save_allocations_report(file_name_prefix = all.first.provider.provider_code)
        file_data = SpreadsheetArchitect.to_xlsx(
          data: all.allocations_report_data
        )
        file_name_suffix = SecureRandom.uuid
        file_name = "allocations-#{file_name_prefix}-#{file_name_suffix}.xlsx"
        file_path = Rails.root.join("public", file_name)

        File.write(file_path, file_data, mode: 'w+b')
      end

      def allocations_report_csv
        SpreadsheetArchitect.to_csv(data: all.allocations_report_data)
      end

      def allocations_report_headers
        [
          'Academic Year',
          'Requested By (Name)',
          'Requested by (UKPRN)',
          'Partner ITT Provider (Name)',
          'Partner ITT provider (UKPRN)',
          'Allocation Subject',
          'Route',
          'Course Aim',
          'Course Level',
          'Min. no. of recruits',
          'Forecast no. of recruits ',
          '3 Year Intention',
          'Awarding Institution',
          'Other Institution',
        ]
      end

      def allocations_report_data
        [allocations_report_headers] +
          all
            .include_allocations_report_data
            .map(&:allocations_report_fields).flatten(1)
      end
    end

    def allocations_report_fields
      allocation_subjects.map do |subject|
        [
          '2020/21',
          accrediting_provider&.provider_name,
          '',
          provider.provider_name,
          provider.organisations.first&.school_nctl_organisation&.urn,
          subject,
          program_type,
          qualification,
          'PG',
          '',
          '',
          '',
          '',
          '',
        ]
      end
    end
  end
end
