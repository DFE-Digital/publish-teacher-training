module DataHub
  module RegisterSchoolImporter
    class RowParser
      def initialize(row)
        @row = row
      end

      def provider_code
        csv_provider_code.presence || csv_accredited_provider_code
      end

      def urns
        raw = @row["placement_urns"]
        return [] if raw.blank?

        raw.strip[1..-2].split(",").map { |u| u.gsub(/[\s'"]/, "") }
      end

    private

      def csv_provider_code
        value = @row["provider_code"]

        value.to_s.strip.presence
      end

      def csv_accredited_provider_code
        value = @row["register_accredited_provider_code"] || @row["accredited_provider_code"]

        value.to_s.strip.presence
      end
    end
  end
end
