require "csv"

class AllocationImporterService
  attr_reader :path_to_csv

  def initialize(path_to_csv:)
    @path_to_csv = path_to_csv
  end

  def execute
    rows.each do |row|
      training_provider = Provider.where(recruitment_cycle_id: 2).find_by(provider_code: row["training_provider_code"])
      accredited_body_provider = Provider.where(recruitment_cycle_id: 2).find_by(provider_code: row["accredited_body_provider_code"])

      if training_provider.blank?
        raise RuntimeError.new("Training Provider with code: #{row['training_provider_code']} not found")
      end

      if accredited_body_provider.blank?
        raise RuntimeError.new("Accredited Body Provider with code: #{row['accredited_body_provider_code']} not found")
      end

      puts "Importing training_provider: #{training_provider.provider_code} and accredited_body: #{accredited_body_provider.provider_code}"

      Allocation.find_or_create_by!(provider: training_provider,
                                    accredited_body: accredited_body_provider,
                                    number_of_places: row["allocation"])
    end
  end

private

  def rows
    @rows ||= CSV.read(path_to_csv, headers: :first_row)
  end
end
