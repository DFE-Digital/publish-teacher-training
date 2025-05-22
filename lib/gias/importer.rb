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

      school_records.each do |school|
        gs = GiasSchool.find_or_initialize_by(urn: school["urn"])
        gs.assign_attributes(school)
        if gs.changed?
          gs.save!
        end
      end

      Log.log("Gias::Importer", "GIAS Data Imported!")
    end
  end
end
