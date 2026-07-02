# frozen_string_literal: true

module Support
  module DataExports
    class Base
      def to_csv(data_for_export: data)
        require "csv"

        header_row = data_for_export.first.keys

        csv_string = CSV.generate(headers: true) do |rows|
          rows << header_row
          data_for_export.map(&:values).each do |value|
            rows << value
          end
        end

        "\uFEFF" + csv_string
      end

      def filename
        "#{self.class.name.parameterize}_#{Time.zone.now.strftime('%Y-%m-%d_%H-%M_%S')}.csv"
      end
    end
  end
end
