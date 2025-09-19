# frozen_string_literal: true

# DataHub namespace which stores import logs and summaries
module DataHub
  # Namespace for course naming change functionality
  module CourseNamingChange
    # Service object that applies bulk course renames defined in a CSV file and
    # produces a summary report. It supports dry-run mode and surfaces warnings
    # when the number of courses changed deviates significantly from the
    # expected count provided in the file.
    class Runner
      class << self
        def fetch_recruitment_cycle(year)
          return RecruitmentCycle.find_by!(year:) if year.present?

          RecruitmentCycle.current
        end

        # Normalise the absolute threshold value, falling back to the default.
        #
        # @param value [String, Integer, nil]
        # @return [Integer]
        def parse_absolute_threshold(value)
          return DEFAULT_ABSOLUTE_WARNING_THRESHOLD if value.blank?

          Integer(value)
        rescue ArgumentError
          raise ArgumentError, "Invalid ABSOLUTE_THRESHOLD: '#{value}'"
        end

        # Normalise the percentage threshold value, falling back to the default.
        #
        # @param value [String, Float, nil]
        # @return [Float]
        def parse_percentage_threshold(value)
          return DEFAULT_PERCENTAGE_WARNING_THRESHOLD if value.blank?

          Float(value)
        rescue ArgumentError
          raise ArgumentError, "Invalid PERCENTAGE_THRESHOLD: '#{value}'"
        end
      end

      COURSE_NAME_KEY = "course name"
      COUNT_KEY = "count"
      REPLACEMENT_KEY = "replacement name"
      REPLACEMENT_ALTERNATE_KEY = "replacement"

      DEFAULT_ABSOLUTE_WARNING_THRESHOLD = 5
      DEFAULT_PERCENTAGE_WARNING_THRESHOLD = 0.2

      # @param csv_path [String] path to the CSV describing course name changes
      # @param recruitment_cycle [RecruitmentCycle] cycle whose courses are targeted
      # @param dry_run [Boolean] when true no database writes are performed
      # @param output [#puts] logger-like object used for streaming feedback
      # @param absolute_warning_threshold [Integer] minimum difference that should raise a warning
      # @param percentage_warning_threshold [Float] proportional difference (relative to expected) that should raise a warning
      def initialize(csv_path:, recruitment_cycle:, dry_run:, output: $stdout, absolute_warning_threshold: DEFAULT_ABSOLUTE_WARNING_THRESHOLD, percentage_warning_threshold: DEFAULT_PERCENTAGE_WARNING_THRESHOLD)
        raise ArgumentError, "csv_path must be provided" if csv_path.blank?
        raise ArgumentError, "CSV file not found: #{csv_path}" unless File.exist?(csv_path)
        raise ArgumentError, "recruitment_cycle must be provided" if recruitment_cycle.nil?

        @csv_path = csv_path
        @recruitment_cycle = recruitment_cycle
        @dry_run = dry_run
        @output = output
        @absolute_warning_threshold = absolute_warning_threshold
        @percentage_warning_threshold = percentage_warning_threshold
      end

      # Execute the CSV processing and return a report summarising the result.
      #
      # @return [DataHub::CourseNamingChange::Report]
      def call
        summary_record = DataHub::CourseNamingChangeSummary.start!

        rows = process_rows
        report = build_report(rows)
        finalise_summary!(summary_record, rows, report)

        report
      rescue StandardError => e
        summary_record.fail!(e)
        raise
      end

    private

      attr_reader :csv_path,
                  :recruitment_cycle,
                  :dry_run,
                  :output,
                  :absolute_warning_threshold,
                  :percentage_warning_threshold

      alias_method :dry_run?, :dry_run

      # Parse each CSV row into a RowResult collection.
      #
      # @return [Array<DataHub::CourseNamingChange::RowResult>]
      def process_rows
        rows = []

        each_row_with_index do |raw_row, line_number|
          normalized_row = normalize_row(raw_row)
          course_name = normalized_row[COURSE_NAME_KEY]
          replacement_name = normalized_row[REPLACEMENT_KEY] || normalized_row[REPLACEMENT_ALTERNATE_KEY]
          expected_count = parse_expected_count(normalized_row[COUNT_KEY])

          next if skip_row?(course_name, replacement_name)

          ensure_course_name!(course_name, line_number)
          rows << process_row(
            line_number: line_number,
            course_name: course_name,
            replacement_name: replacement_name,
            expected_count: expected_count,
          )
        end

        rows
      end

      # Build the summary report and emit the aggregated log output.
      #
      # @param rows [Array<DataHub::CourseNamingChange::RowResult>]
      # @return [DataHub::CourseNamingChange::Report]
      def build_report(rows)
        Report.new(rows: rows, dry_run: dry_run?).tap do |report|
          log_summary(report)
        end
      end

      # Persist the short and full summaries to the summary record.
      #
      # @param summary_record [DataHub::CourseNamingChangeSummary]
      # @param rows [Array<DataHub::CourseNamingChange::RowResult>]
      # @param report [DataHub::CourseNamingChange::Report]
      # @return [void]
      def finalise_summary!(summary_record, rows, report)
        summary_record.finish!(
          short_summary: build_short_summary(report),
          full_summary: build_full_summary(rows, report),
        )
      end

      # Transform a CSV row into a RowResult, applying or simulating the change.
      #
      # @param line_number [Integer]
      # @param course_name [String]
      # @param replacement_name [String, nil]
      # @param expected_count [Integer, nil]
      # @return [DataHub::CourseNamingChange::RowResult]
      def process_row(line_number:, course_name:, replacement_name:, expected_count:)
        matched_courses = matching_courses_for(course_name)
        actual_count = matched_courses.size

        row_result = if replacement_name.blank?
                       build_missing_replacement_row(
                         line_number: line_number,
                         course_name: course_name,
                         expected_count: expected_count,
                         actual_count: actual_count,
                         matched_courses: matched_courses,
                       )
                     else
                       build_standard_row(
                         line_number: line_number,
                         course_name: course_name,
                         replacement_name: replacement_name,
                         expected_count: expected_count,
                         matched_courses: matched_courses,
                         actual_count: actual_count,
                       )
                     end

        log_row(row_result)
        row_result
      end

      # Determine whether the row can be ignored entirely.
      #
      # @param course_name [String, nil]
      # @param replacement_name [String, nil]
      # @return [Boolean]
      def skip_row?(course_name, replacement_name)
        course_name.blank? && replacement_name.blank?
      end

      # Validate the presence of course name data for the given row.
      #
      # @param course_name [String]
      # @param line_number [Integer]
      # @return [void]
      def ensure_course_name!(course_name, line_number)
        raise ArgumentError, "Row #{line_number}: course name is blank" if course_name.blank?
      end

      # Construct a RowResult when the replacement name is missing.
      #
      # @param line_number [Integer]
      # @param course_name [String]
      # @param expected_count [Integer, nil]
      # @param actual_count [Integer]
      # @param matched_courses [Array<Course>]
      # @return [DataHub::CourseNamingChange::RowResult]
      def build_missing_replacement_row(line_number:, course_name:, expected_count:, actual_count:, matched_courses:)
        RowResult.new(
          line_number: line_number,
          course_name: course_name,
          replacement_name: course_name,
          expected_count: expected_count,
          actual_count: actual_count,
          course_identifiers: identifiers_for(matched_courses),
          warning: true,
          warning_reason: "Replacement name missing; no changes applied",
        )
      end

      # Construct a RowResult when a replacement name is present. Applies the change unless in dry-run.
      #
      # @param line_number [Integer]
      # @param course_name [String]
      # @param replacement_name [String]
      # @param expected_count [Integer, nil]
      # @param matched_courses [Array<Course>]
      # @param actual_count [Integer]
      # @return [DataHub::CourseNamingChange::RowResult]
      def build_standard_row(line_number:, course_name:, replacement_name:, expected_count:, matched_courses:, actual_count:)
        apply_replacement!(matched_courses, replacement_name) unless dry_run?

        warning, warning_reason = evaluate_warning(expected_count, actual_count)

        RowResult.new(
          line_number: line_number,
          course_name: course_name,
          replacement_name: replacement_name,
          expected_count: expected_count,
          actual_count: actual_count,
          course_identifiers: identifiers_for(matched_courses),
          warning: warning,
          warning_reason: warning_reason,
        )
      end

      # Iterate through each CSV record, yielding row data alongside its 1-based
      # line number (including the header).
      #
      # @yieldparam row [CSV::Row]
      # @yieldparam line_number [Integer]
      # Iterate through the CSV content yielding each row and logical line number.
      #
      # @yieldparam row [CSV::Row]
      # @yieldparam line_number [Integer]
      # @return [Enumerator, nil]
      def each_row_with_index(&block)
        return enum_for(__method__) unless block_given?

        raw_content = File.binread(csv_path)
        cleaned_content = raw_content.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
        cleaned_content.delete_prefix!("﻿")

        csv_reader = CSV.new(StringIO.new(cleaned_content), headers: true)

        csv_reader.each.with_index(2, &block)
      end

      # Convert CSV keys to lowercase strings without surrounding whitespace to
      # simplify comparisons regardless of how headings are capitalised.
      #
      # @param row [CSV::Row]
      # @return [Hash{String=>String,nil}]
      def normalize_row(row)
        row
          .to_h
          .transform_keys { |key| key.to_s.strip.downcase }
          .transform_values { |value| sanitize_field(value) }
      end

      # Ensure a field is UTF-8 encoded, replacing invalid bytes.
      #
      # @param value [Object]
      # @return [Object]
      def sanitize_field(value)
        return value unless value.is_a?(String)

        # Had some encoding errors when I tried to import the CSV shared by Katie, below fixes this
        value.encode("UTF-8", invalid: :replace, undef: :replace, replace: "").scrub
      end

      # Fetch all courses in the recruitment cycle whose `name` matches the CSV
      # value exactly. Providers are eager-loaded so that identifiers can be
      # generated later without extra queries.
      #
      # @param course_name [String]
      # @return [Array<Course>]
      # Fetch courses whose name matches the CSV entry.
      #
      # @param course_name [String]
      # @return [Array<Course>]
      def matching_courses_for(course_name)
        recruitment_cycle
          .courses
          .kept
          .includes(:provider)
          .where(name: course_name)
          .to_a
      end

      # Persist the replacement name on each provided course inside a single
      # transaction. No work is performed when the list is empty.
      #
      # @param courses [Array<Course>]
      # @param replacement_name [String]
      # @return [void]
      # Persist the new name on matched courses inside a transaction.
      #
      # @param courses [Array<Course>]
      # @param replacement_name [String]
      # @return [void]
      def apply_replacement!(courses, replacement_name)
        return if courses.empty?

        Course.transaction do
          courses.each do |course|
            course.update!(name: replacement_name)
          end
        end
      end

      # Convert the set of courses into human-readable identifiers combining the
      # provider and course codes.
      #
      # @param courses [Array<Course>]
      # @return [Array<String>]
      # Present a list of identifiers for reporting.
      #
      # @param courses [Array<Course>]
      # @return [Array<String>]
      def identifiers_for(courses)
        courses.map { |course| "#{course.provider.provider_code}/#{course.course_code}" }
      end

      # Parse the expected count value from the CSV, returning nil for blank
      # entries while raising an informative error for invalid input.
      #
      # @param value [String, nil]
      # @return [Integer, nil]
      # Parse a numeric expected count, allowing blank values.
      #
      # @param value [String, nil]
      # @return [Integer, nil]
      def parse_expected_count(value)
        return nil if value.blank?

        Integer(value)
      rescue ArgumentError
        raise ArgumentError, "Unable to parse expected count '#{value}'"
      end

      # Determine whether a warning should be emitted for the difference between
      # expected and actual counts using both absolute and proportional
      # thresholds.
      #
      # @param expected_count [Integer, nil]
      # @param actual_count [Integer]
      # @return [Array<(Boolean, String, nil)>]
      # Decide whether the difference between expected and actual warrants a warning.
      #
      # @param expected_count [Integer, nil]
      # @param actual_count [Integer]
      # @return [Array<(Boolean, String)>]
      def evaluate_warning(expected_count, actual_count)
        return [false, nil] if expected_count.nil?

        difference = (actual_count - expected_count).abs
        threshold = [absolute_warning_threshold, (expected_count * percentage_warning_threshold).ceil].max

        if difference >= threshold
          warning_reason = "Expected #{expected_count}, changed #{actual_count}, threshold #{threshold}"
          [true, warning_reason]
        else
          [false, nil]
        end
      end

      # Collate headline metrics for persistence.
      #
      # @param report [DataHub::CourseNamingChange::Report]
      # @return [Hash]
      def build_short_summary(report)
        {
          "dry_run" => report.dry_run?,
          "processed_rows" => report.processed_rows,
          "total_expected" => report.total_expected,
          "total_actual" => report.total_actual,
          "total_difference" => report.total_difference,
          "warnings" => report.warnings_count,
        }
      end

      # Collate detailed row information for persistence.
      #
      # @param rows [Array<DataHub::CourseNamingChange::RowResult>]
      # @param report [DataHub::CourseNamingChange::Report]
      # @return [Hash]
      def build_full_summary(rows, report)
        {
          "dry_run" => report.dry_run?,
          "generated_at" => Time.current.iso8601,
          "rows" => rows.map(&:to_h),
          "flagged_rows" => report.flagged_rows.map(&:line_number),
        }
      end

      # Emit a per-row log line to aid support when reviewing results.
      #
      # @param row [DataHub::CourseNamingChange::RowResult]
      # @return [void]
      # Emit a log line for a single processed row.
      #
      # @param row [DataHub::CourseNamingChange::RowResult]
      # @return [void]
      def log_row(row)
        prefix = dry_run? ? "[DRY RUN]" : "[APPLY]"
        expected_display = row.expected_count.nil? ? "n/a" : row.expected_count
        diff_display = row.difference.nil? ? "n/a" : sprintf("%+d", row.difference)
        identifiers = row.course_identifiers
        identifiers = %w[none] if identifiers.empty?

        message = sprintf(
          "%s line=%d name='%s' -> '%s' expected=%s actual=%d diff=%s identifiers=%s",
          prefix,
          row.line_number,
          row.course_name,
          row.replacement_name,
          expected_display,
          row.actual_count,
          diff_display,
          identifiers.join(";"),
        )

        message = "#{message} WARNING: #{row.warning_reason}" if row.warning?

        output.puts(message)
      end

      # Emit a summary once the CSV has been processed, highlighting any rows
      # that exceeded the configured thresholds.
      #
      # @param report [DataHub::CourseNamingChange::Report]
      # @return [void]
      # Emit a summary log line at the end of the run.
      #
      # @param report [DataHub::CourseNamingChange::Report]
      # @return [void]
      def log_summary(report)
        prefix = report.dry_run? ? "[DRY RUN]" : "[APPLY]"

        output.puts sprintf(
          "%s processed_rows=%d expected_total=%d actual_total=%d diff=%+d",
          prefix,
          report.processed_rows,
          report.total_expected,
          report.total_actual,
          report.total_difference,
        )

        return if report.flagged_rows.empty?

        output.puts sprintf(
          "%s WARNING rows exceeding threshold: %s",
          prefix,
          report.flagged_rows.map { |row| "line #{row.line_number}" }.join(", "),
        )
      end
    end
  end
end
