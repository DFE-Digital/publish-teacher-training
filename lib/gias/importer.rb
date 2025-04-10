# frozen_string_literal: true

require "csv"

module Gias
  class Importer < Service
    def initialize(csv_path)
      @csv_path = csv_path
    end

    attr_reader :csv_path

    def call
      Log.log("Gias::Importer", "Importing GIAS schools...")

      school_records = CSV.foreach(csv_path, headers: true).map(&:to_h)

      GiasSchool.upsert_all(school_records, unique_by: :urn)

      Log.log("Gias::Importer", "GIAS Data Imported!")
    end
  end
end
