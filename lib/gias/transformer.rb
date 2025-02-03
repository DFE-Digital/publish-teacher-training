# frozen_string_literal: true

module Gias
  class Transformer < Service
    COLUMNS =
      {
        'URN' => 'urn',
        'EstablishmentName' => 'name',
        'TypeOfEstablishment (code)' => 'type_code',
        'EstablishmentTypeGroup (code)' => 'group_code',
        'EstablishmentStatus (code)' => 'status_code',
        'PhaseOfEducation (code)' => 'phase_code',
        'StatutoryLowAge' => 'minimum_age',
        'StatutoryHighAge' => 'maximum_age',
        'UKPRN' => 'ukprn',
        'Street' => 'address1',
        'Locality' => 'address2',
        'Address3' => 'address3',
        'Town' => 'town',
        'County (name)' => 'county',
        'Postcode' => 'postcode',
        'SchoolWebsite' => 'website',
        'TelephoneNum' => 'telephone',
        'Latitude' => 'latitude',
        'Longitude' => 'longitude'
      }.freeze

    def initialize(input_file)
      @input_file = input_file
      @output_file = Tempfile.new
    end

    def call
      Log.log('Gias::Transformer', 'Starting transformation of GIAS schools download...')
      output_csv = CSV.new(output_file)

      CSV.new(input_file, headers: true, return_headers: true).each do |row|
        if row.header_row?
          output_csv << header_row
        elsif (school = School.new(row)).valid?
          output_csv << school.transformed_row
        end
      end

      Log.log('Gias::Transformer', 'Transformation of GIAS schools download complete!')

      FileUtils.rm_f(input_file)
      # Rewind the file so it's ready for reading
      output_file.rewind
      output_file
    end

    private

    attr_reader :input_file, :output_file

    def header_row
      COLUMNS.values
    end

    class CoordinateTransformer
      def initialize(northing, easting)
        @northing = northing
        @easting = easting
      end

      attr_reader :northing, :easting

      def call
        result = ActiveRecord::Base.connection.execute(format(<<~SQL.squish, easting, northing))
          WITH point as (
            SELECT ST_AsText(ST_Transform(ST_SetSRID(ST_MakePoint(%f, %f), 27700), 4327)) as text
          )
          SELECT ST_Y(text) as latitude, ST_X(text) as longitude from point;
        SQL

        [result.first['latitude'], result.first['longitude']]
      end
    end

    class School
      # Code | EstablishmentStatus
      # 1    | Open
      # 3    | Open, but proposed to close
      OPEN_SCHOOL_CODES = %w[1 3].freeze
      # Code | Establishment type
      # 25   | Offshore schools
      # 30   | Welsh establishment
      # 37   | British schools overseas
      NON_ENGLISH_ESTABLISHMENTS = %w[25 30 37].freeze

      attr_reader :row

      def initialize(row)
        @row = row
      end

      def valid?
        northing_and_easting_present? && open? && in_england?
      end

      def transformed_row
        coords = CoordinateTransformer.new(row.fetch('Northing'), row.fetch('Easting')).call

        row.to_h.slice(*COLUMNS.keys).values + coords
      end

      private

      def open?
        OPEN_SCHOOL_CODES.include? row.fetch('EstablishmentStatus (code)')
      end

      def in_england?
        NON_ENGLISH_ESTABLISHMENTS.exclude?(row.fetch('TypeOfEstablishment (code)'))
      end

      def northing_and_easting_present?
        return true if row['Northing'].present? && row['Easting'].present?

        Log.log('Gias::Transformer', 'row has no coordinates')
        false
      end
    end
  end
end
