module AllocationsReport
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    # Outputs an allocations XLSX with a randomly generated suffix to `public/`.
    # The first argument is an optional prefix for the filename to make it
    # easier to differentiate among ~200 other similar XLSX files. Defaults to
    # the NCTL ID.
    # The filename will have a UUID prefix so that it can be hosted
    # and linked to from an Azure bucket, but that the names can't be
    # simply guessed.
    def save_allocations_report(file_name_prefix = nctl_id)
      file_data = SpreadsheetArchitect.to_xlsx(
        data: allocations_report_data
      )
      file_name_suffix = SecureRandom.uuid
      file_name = "allocations-#{file_name_prefix}-#{file_name_suffix}.xlsx"
      file_path = Rails.root.join("public", file_name)

      File.write(file_path, file_data, mode: 'w+b')
    end

    def allocations_report_csv
      SpreadsheetArchitect.to_csv(data: allocations_report_data)
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
        'Forecast no. of recruits',
        '3 Year Intention',
        'Awarding Institution',
        'Other Institution',
      ]
    end

    def allocations_report_data
      [allocations_report_headers] +
        padded_allocation_requests_for(courses)
    end

    def padded_allocation_requests_for(courses)
      AllocationRequestCollection
        .new(courses)
        .to_a
        .map { |request| request.to_a + ([''] * 5) }
    end
  end
end
