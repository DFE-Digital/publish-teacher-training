module RegisterSchoolImporter
  class ImportOrchestrator
    def initialize(recruitment_cycle:, csv_path:, school_creator_class: SchoolCreator)
      @recruitment_cycle = recruitment_cycle
      @csv_path = csv_path
      @school_creator_class = school_creator_class
    end

    def run!
      import_record = DataHub::RegisterSchoolImportSummary.create!(
        started_at: Time.current,
        status: "started",
        short_summary: {},
        full_summary: {},
      )

      summary = Importer.new(
        recruitment_cycle: @recruitment_cycle,
        csv_path: @csv_path,
        school_creator_class: @school_creator_class,
      ).call

      import_record.update!(
        finished_at: Time.current,
        status: "finished",
        short_summary: summary.meta,
        full_summary: summary.full_summary,
      )

      import_record
    rescue StandardError => e
      import_record.update!(
        finished_at: Time.current,
        status: "failed",
        short_summary: {
          error_class: e.class.to_s,
          error_message: e.message,
          backtrace: e.backtrace,
        },
      )

      raise e
    end
  end
end
