# frozen_string_literal: true

require 'csv'

module CSVImports
  class LocationsService
    include ServicePattern

    def initialize(csv_content:, provider:)
      @csv_content = csv_content
      @provider = provider
    end

    def call
      csv_content_with_header = "#{HEADERS.join(',')}\n#{csv_content}"

      CSV.new(csv_content_with_header, headers: true, header_converters: :symbol)
         .map { |row| Site.new(row.to_h.merge(provider_id: provider.id)) }
    end

    private

    attr_reader :csv_content, :provider

    HEADERS = %i[location_name urn address1 address2 address3 address4 postcode].freeze
  end
end
