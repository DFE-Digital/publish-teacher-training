require "csv"

class AllocationImporterService
  attr_reader :path_to_csv

  def initialize(path_to_csv:)
    @path_to_csv = path_to_csv
  end

  def execute
    rows.each do |row|
      training_provider = Provider.where(recruitment_cycle_id: 1).find_by(provider_code: row["provider_code"])
      accredited_body_provider = Provider.where(recruitment_cycle_id: 1).find_by(provider_code: row["accredited_body_code"])

      if training_provider.blank?
        raise "Training Provider with code: #{row['provider_code']} not found"
      end

      if accredited_body_provider.blank?
        raise "Accredited Body Provider with code: #{row['accredited_body_code']} not found"
      end

      puts "Importing training_provider: #{training_provider.provider_code} and accredited_body: #{accredited_body_provider.provider_code}"

      allocation = Allocation.find_or_initialize_by(
        provider: training_provider,
        accredited_body: accredited_body_provider,
        recruitment_cycle_id: 1,
        provider_code: training_provider.provider_code,
        accredited_body_code: accredited_body_provider.provider_code,
      )

      allocation.number_of_places = row["number_of_places"]

      if allocation.changed?
        allocation.save!
      end
    end
  end

private

  def rows
    @rows ||= CSV.read(path_to_csv, headers: :first_row)
  end
end
