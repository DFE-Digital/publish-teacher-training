# frozen_string_literal: true

module DataHub
  module DuplicateSchools
    # Classifies the providers holding the same school twice and records what it
    # found in the process summary table.
    #
    #   DataHub::DuplicateSchools::Executor.new(years: %w[2026]).execute
    #
    # Nothing about the duplicates is changed - which shape gets merged, and
    # onto which row, is a decision to take from the recorded evidence. The only
    # row this writes is its own summary.
    class Executor
      # @param years [Array<String>] recruitment cycle years to classify
      # @param io [IO] where the human-readable report is printed
      def initialize(years:, io: $stdout)
        @years = Array(years).map(&:to_s)
        @io = io
      end

      # @return [DataHub::DuplicateSchoolsProcessSummary]
      def execute
        process_summary = DataHub::DuplicateSchoolsProcessSummary.start!

        groups = Classifier.new(years:).call
        summary_builder = SummaryBuilder.new(groups:, years:)

        Reporter.new(groups:, years:, io:).call

        process_summary.finish!(
          short_summary: summary_builder.short_summary,
          full_summary: summary_builder.full_summary,
        )

        process_summary
      rescue StandardError => e
        process_summary&.fail!(e)
        raise e
      end

    private

      attr_reader :years, :io
    end
  end
end
