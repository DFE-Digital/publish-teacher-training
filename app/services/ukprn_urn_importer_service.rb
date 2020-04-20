require "csv"

class UkprnUrnImporterService
  attr_reader :path_to_csv

  VALID_HEADERS = %w{provider_code urn ukprn}.freeze

  def initialize(path_to_csv:)
    @path_to_csv = path_to_csv
  end

  def execute
    check_headers!

    rows.each do |row|
      provider = Provider.find_by(provider_code: row["provider_code"])

      raise RuntimeError.new("Provider not found for: #{row['provider_code']}") unless provider

      puts "Updating Provider: #{row['provider_code']} with ukprn: #{row['ukprn']} and urn: #{row['urn']}"

      provider.ukprn = row["ukprn"] if row["ukprn"].present?
      provider.urn = row["urn"] if row["urn"].present?
      provider.save!
    end
  end

private

  def check_headers!
    unless (rows.headers & VALID_HEADERS).size == 3
      raise RuntimeError.new("Invalid CSV headers")
    end
  end

  def rows
    @rows ||= CSV.read(path_to_csv, headers: :first_row)
  end
end
