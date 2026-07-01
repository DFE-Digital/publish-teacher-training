# frozen_string_literal: true

require "csv"

module Exports
  class AccreditedCourseList
    CSV_HEADERS = [
      "Provider",
      "Course name",
      "Course code",
      "Status",
      "Age range",
      "Fee or salary",
      "Qualification",
      "Full time or part time",
      "Course start date",
      "Course length",
      "Fee for UK citizens",
      "Fee for international students",
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
      "\uFEFF" + CSV.generate(headers: CSV_HEADERS, write_headers: true) do |csv| # rubocop:disable Style/StringConcatenation
        courses.each do |course|
          decorated_course = course.decorate

          enrichment = current_enrichment_for(course)

          csv << [
            decorated_course.provider.provider_name,
            decorated_course.name,
            decorated_course.course_code,
            status(course),
            decorated_course.age_range,
            decorated_course.funding.titleize,
            decorated_course.outcome,
            decorated_course.study_mode&.humanize,
            format_date(decorated_course.start_date),
            # LONG FORM CONTENT
            # Course length and fees section
            enrichment&.course_length&.underscore&.humanize,
            enrichment&.fee_uk_eu && "£#{enrichment.fee_uk_eu}",
            enrichment&.fee_international && "£#{enrichment.fee_international}",
            combined_field(
              enrichment&.fee_schedule,
              enrichment&.additional_fees,
              enrichment&.financial_support,
            ),
            # Where you will train section
            combined_field(
              enrichment&.placement_selection_criteria,
              enrichment&.duration_per_school,
              enrichment&.theoretical_training_location,
              enrichment&.theoretical_training_duration,
            ),
            # What you will do on school placements section
            combined_field(
              enrichment&.placement_school_activities,
              enrichment&.support_and_mentorship,
            ),
            # What you will study section
            combined_field(
              enrichment&.theoretical_training_activities,
              enrichment&.assessment_methods,
            ),
            # Interview process section
            combined_field(
              interview_location(enrichment),
              enrichment&.interview_process,
            ),
            decorated_course.find_url,
          ]
        end
      end
    end

    def filename
      "courses-#{Time.zone.today}.csv"
    end

  private

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
        .join("\n")
        .presence
    end

    def interview_location(enrichment)
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

    attr_reader :courses
  end
end
