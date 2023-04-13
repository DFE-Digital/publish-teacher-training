# frozen_string_literal: true

require 'csv'

module CSVImports
  class SchoolsService
    include ServicePattern

    def initialize(csv_content:, provider:)
      @csv_content = csv_content
      @provider = provider
    end

    def call
      CSV.new(csv_content).map do |row|
        attributes = { provider_id: provider.id }
        HEADERS.each_with_index { |k, i| attributes[k] = row[i] }
        Site.new(attributes)
      end
    end

    private

    attr_reader :csv_content, :provider

    HEADERS = %i[location_name urn address1 address2 address3 town address4 postcode].freeze
  end
end
