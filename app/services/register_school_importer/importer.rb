module RegisterSchoolImporter
  class Importer
    attr_reader :summary

    def initialize(recruitment_cycle:, csv_path:, school_creator_class: SchoolCreator)
      @recruitment_cycle = recruitment_cycle
      @csv_path = csv_path
      @school_creator_class = school_creator_class
      @summary = ImportSummary.new
    end

    def call
      CSV.foreach(@csv_path, headers: true).with_index(2) do |row, row_number|
        process_row(row, row_number)
      end

      @summary
    end

  private

    def process_row(row, row_number)
      parser = RowParser.new(row)
      provider_code = parser.provider_code
      provider = resolve_provider(parser)

      return @summary.mark_provider_not_found(provider_code, row_number) if provider.nil?

      result = create_schools(provider, parser.urns, row_number)

      @summary.mark_ignored_schools(provider_code, result.ignored_urns) if result.ignored_urns.any?
      @summary.mark_schools_added(provider_code, result.schools_added) if result.schools_added.any?
      @summary.mark_school_errors(provider_code, result.school_errors) if result.school_errors.any?
    end

    def resolve_provider(parser)
      ProviderResolver.new(@recruitment_cycle, parser).resolve
    end

    def create_schools(provider, urns, row_number)
      @school_creator_class.new(provider:, urns:, row_number:).call
    end
  end
end
