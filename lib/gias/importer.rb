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

      school_records.each do |school_record|
        gias_school = GiasSchool.find_or_initialize_by(urn: school_record["urn"])

        if preserve_coordinates?(gias_school, school_record)
          school_record["latitude"] = gias_school.latitude
          school_record["longitude"] = gias_school.longitude
        end

        gias_school.assign_attributes(school_record)

        if gias_school.changed?
          gias_school.save!
        end
      end

      Log.log("Gias::Importer", "GIAS Data Imported!")
    end

  private

    def preserve_coordinates?(gias_school, school_record)
      gias_school.latitude.present? && gias_school.longitude.present? &&
        school_record["latitude"].blank? && school_record["longitude"].blank?
    end
  end
end
