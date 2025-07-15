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

      raw.strip[1..-2].split(",").map { |u| u.strip.gsub(/\A['"]|['"]\z/, "") }
    end

  private

    def csv_provider_code
      value = @row["provider_code"]
      value.present? ? value.strip : nil
    end

    def csv_accredited_provider_code
      value = @row["register_accredited_provider_code"] || @row["accredited_provider_code"]
      value.present? ? value.strip : nil
    end
  end
end
