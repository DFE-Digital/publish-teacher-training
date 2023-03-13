# frozen_string_literal: true

require 'csv'

module CSVImports
  class GiasImport
    include ServicePattern

    def initialize(csv_path)
      @csv_path = csv_path
      @logger = Logger.new($stdout)
    end

    def call
      upserted = 0
      rows = 0
      errors = []

      CSV.foreach(@csv_path, headers: true, encoding: 'iso-8859-1:utf-8').with_index(2) do |school, row_number|
        next if school_excluded?(school)

        begin
          GiasSchool.find_or_initialize_by(urn: school['URN'])
                    .update!(
                      name: school['EstablishmentName'],
                      type_code: school['TypeOfEstablishment (code)'],
                      group_code: school['EstablishmentTypeGroup (code)'],
                      status_code: school['EstablishmentStatus (code)'],
                      phase_code: school['PhaseOfEducation (code)'],
                      minimum_age: school['StatutoryLowAge'],
                      maximum_age: school['StatutoryHighAge'],
                      ukprn: school['UKPRN'],
                      address1: school['Street'],
                      address2: school['Locality'],
                      address3: school['Address3'],
                      town: school['Town'],
                      county: school['County (name)'],
                      postcode: school['Postcode'],
                      website: school['SchoolWebsite'],
                      telephone: school['TelephoneNum']
                    )
        rescue ActiveRecord::RecordInvalid => e
          errors << e.record.errors.messages
          errors << row_number
        else
          upserted += 1
        end
        rows += 1
      end
      @logger.info "Done! #{upserted} schools upserted"
      @logger.info "Failures #{rows - upserted}"
      @logger.info "Errors - #{errors.inspect}" if errors.any?
    end

    private

    def school_excluded?(school)
      %w[1 3].exclude?(school['EstablishmentStatus (code)']) ||
        school['PhaseOfEducation (code)'] == '1' ||
        %w[3 6].include?(school['EstablishmentTypeGroup (code)'])
    end
  end
end
