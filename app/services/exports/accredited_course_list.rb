# frozen_string_literal: true

require "csv"

module Exports
  class AccreditedCourseList
    # These columns are optional and will be removed from the CSV if all rows are blank for that column
    OPTIONAL_COLUMNS = [
      "Non-UK fee",
      "Fees and financial support",
      "Interview process",
    ].freeze

    CSV_HEADERS = [
      "Provider",
      "Course name",
      "Course code",
      "Status",
      "Age range",
      "Fee or salary",
      "Qualification",
      "Full time or part time",
      "Start date",
      "Course length",
      "UK fee",
      "Non-UK fee",
      "Fees and financial support",
      "Where you will train",
      "What you will do on school placements",
      "What you will study",
      "Interview process",
      "View on Find",
    ].freeze

    def initialize(courses:)
      @courses = courses
    end

    def data
      rows = build_rows

      filtered_headers, filtered_rows = filter_optional_blank_columns(rows)

      "\uFEFF#{CSV.generate(headers: filtered_headers, write_headers: true) do |csv|
        filtered_rows.each { |row| csv << row }
      end}"
    end

    def filename
      "courses-#{Time.zone.today}.csv"
    end

  private

    attr_reader :courses

    # Building the provider/course rows for the CSV.
    def build_rows
      courses.map do |course|
        decorated_course = course.decorate
        enrichment = current_enrichment_for(course)

        [
          decorated_course.provider.provider_name,
          decorated_course.name,
          decorated_course.course_code,
          status(course),
          decorated_course.age_range,
          funding_label(course),
          decorated_course.outcome,
          decorated_course.study_mode&.humanize,
          format_date(decorated_course.start_date),

          # Course length & fees
          formatted_course_length(enrichment&.course_length),
          enrichment&.fee_uk_eu && "£#{enrichment.fee_uk_eu}",
          enrichment&.fee_international && "£#{enrichment.fee_international}",

          combined_field(
            enrichment&.fee_schedule,
            enrichment&.additional_fees,
            enrichment&.financial_support,
          ),

          # Where you will train
          combined_field(
            enrichment&.placement_selection_criteria,
            enrichment&.duration_per_school,
            enrichment&.theoretical_training_location,
            enrichment&.theoretical_training_duration,
          ),

          # School placements
          school_placements_field(enrichment),

          # What you will study
          combined_field(
            enrichment&.theoretical_training_activities,
            enrichment&.assessment_methods,
          ),

          # Interview process
          combined_field(
            interview_location(enrichment),
            enrichment&.interview_process,
          ),

          decorated_course.find_url,
        ]
      end
    end

    # Column filtering - removes optional columns from the CSV if all rows are blank for that column.
    def filter_optional_blank_columns(rows)
      return [CSV_HEADERS, rows] if rows.empty?

      columns = rows.transpose

      kept_indexes = CSV_HEADERS.each_index.select do |i|
        header = CSV_HEADERS[i]

        if OPTIONAL_COLUMNS.include?(header)
          columns[i].any?(&:present?)
        else
          true
        end
      end

      filtered_headers = CSV_HEADERS.values_at(*kept_indexes)
      filtered_rows    = rows.map { |row| row.values_at(*kept_indexes) }

      [filtered_headers, filtered_rows]
    end

    # Helpers for formatting and extracting data from the course/enrichments
    def current_enrichment_for(course)
      course.enrichments.max_by { |e| [e.created_at, e.id] }
    end

    def format_date(date)
      date&.strftime("%B %Y")
    end

    def combined_field(*values)
      values
        .map(&:presence)
        .compact
        .join("\r\n")
        .presence
    end

    def interview_location(enrichment)
      return nil unless enrichment

      case enrichment.interview_location
      when "in person"
        "In person interviews"
      when "online"
        "Online interviews"
      when "both"
        "Either in person or online interviews"
      else
        enrichment.interview_location&.humanize
      end
    end

    def status(course)
      if course.is_withdrawn?
        "Withdrawn"
      elsif course.scheduled?
        "Scheduled"
      elsif course.content_status == :draft
        "Draft"
      elsif course.content_status == :rolled_over
        "Rolled over"
      elsif course.open_for_applications?
        "Open"
      elsif course.only_published? && !course.open_for_applications?
        "Closed"
      else
        "Unknown"
      end
    end

    def funding_label(course)
      case course.funding
      when "fee"
        "Fee-paying"
      when "salary"
        "Salary"
      when "apprenticeship"
        "Apprenticeship"
      else
        course.funding.to_s.humanize
      end
    end

    def formatted_course_length(value)
      case value
      when "OneYear"   then "1 year"
      when "TwoYears"  then "2 years"
      when "ThreeYears" then "3 years"
      when "FourYears" then "4 years"
      else
        value&.underscore&.humanize
      end
    end

    def school_placements_field(enrichment)
      text = combined_field(
        enrichment&.placement_school_activities,
        enrichment&.support_and_mentorship,
      )

      return text unless text.present?

      text.include?("\r\n") ? text : "#{text}\r\n"
    end
  end
end
