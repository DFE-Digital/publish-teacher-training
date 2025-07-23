module RegisterSchoolImporter
  class ImportOrchestrator
    def initialize(recruitment_cycle:, csv_path:, school_creator_class: SchoolCreator)
      @recruitment_cycle = recruitment_cycle
      @csv_path = csv_path
      @school_creator_class = school_creator_class
    end

    def run!
      import_record = DataHub::RegisterSchoolImportSummary.start!

      summary = Importer.new(
        recruitment_cycle: @recruitment_cycle,
        csv_path: @csv_path,
        school_creator_class: @school_creator_class,
      ).call

      import_record.finish!(
        short_summary: summary.meta,
        full_summary: summary.full_summary,
      )

      import_record
    rescue StandardError => e
      import_record.fail!(e)
      raise e
    end
  end
end
