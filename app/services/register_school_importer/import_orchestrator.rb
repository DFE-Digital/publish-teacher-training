module RegisterSchoolImporter
  class ImportOrchestrator
    def initialize(recruitment_cycle:, csv_path:, school_creator_class: SchoolCreator)
      @recruitment_cycle = recruitment_cycle
      @csv_path = csv_path
      @school_creator_class = school_creator_class
    end

    def run!
      summary = Importer.new(
        recruitment_cycle: @recruitment_cycle,
        csv_path: @csv_path,
        school_creator_class: @school_creator_class,
      ).call

      Import.create!(
        short_summary: summary.meta,
        full_summary: summary.full_summary,
        import_type: Import.import_types[:register_schools],
      )
    end
  end
end
