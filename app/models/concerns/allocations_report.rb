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
        file_data = all
                      .include_allocations_report_data
                      .to_xlsx(spreadsheet_columns: :allocations_report_columns)

        file_name_suffix = SecureRandom.uuid

        File.open(Rails.root.join("public", "allocations-#{file_name_prefix}-#{file_name_suffix}.xlsx"), 'w+b') do |f|
          f.write file_data
        end
      end

      def allocations_report_csv
        all
          .include_allocations_report_data
          .to_csv(spreadsheet_columns: :allocations_report_columns)
      end
    end

    def allocations_report_columns
      [
        ['Academic Year', '2020/21'],
        ['Requested By (Name)', accrediting_provider&.provider_name],
        ['Requested by (UKPRN)', ''],
        ['Partner ITT Provider (Name)', provider.provider_name],
        ['Partner ITT provider (UKPRN)', provider.organisations.first&.school_nctl_organisation&.urn],
        ['Allocation Subject', allocation_subjects.join(' | ')],
        ['Route', program_type],
        ['Course Aim', qualification],
        ['Course Level', 'PG'],
        ['Min. no. of recruits', ''],
        ['Forecast no. of recruits ', ''],
        ['3 Year Intention', ''],
        ['Awarding Institution', ''],
        ['Other Institution', '']
      ]
    end
  end
end
