require 'rubyXL/convenience_methods'

module AllocationsReport
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    # Outputs an allocations XLSX with a randomly generated suffix to `public/`.
    # The first argument is an optional prefix for the filename to make it
    # easier to differentiate among ~200 other similar XLSX files. Defaults to
    # the UKPRN.
    # The filename will have a UUID prefix so that it can be hosted
    # and linked to from an Azure bucket, but that the names can't be
    # simply guessed.
    def save_allocations_report(template_path, file_name_prefix = ukprn)
      data =
        AllocationRequestCollection.new(self.courses).to_a + # put the core courses at the top of the spreadsheet
        AllocationRequestCollection.new(self.courses_accredited_by_this_organisation).to_a

      workbook = RubyXL::Parser.parse(template_path)
      worksheet = workbook["Requests Sheet "]

      row_offset = 6
      data.each_with_index do |row, row_index|
        row.to_a.each_with_index do |value, column_index|
          cell = worksheet[row_offset + row_index][column_index]

          cell.nil? ? worksheet.add_cell(row_offset + row_index, column_index, value) : cell.change_contents(value)
        end
      end

      file_name_suffix = SecureRandom.uuid
      file_name = "Allocations_requests_ITT2020-#{file_name_prefix}-#{file_name_suffix}.xlsx"
      output_filename = Rails.root.join("public", file_name)

      workbook.write(output_filename)
    end
  end
end
