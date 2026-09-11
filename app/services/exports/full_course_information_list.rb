# frozen_string_literal: true

require "csv"

module Exports
  # Every course description section as the provider wrote it, one row per
  # course. CourseInformationList carries the basic fields only, which is not
  # enough to review a cycle's copy away from Publish, so this repeats those
  # columns and adds each long-form section beside them.
  #
  # The text goes out as the markdown held on the enrichment rather than
  # rendered HTML, so an amended cell pastes straight back into Publish. The
  # enrichment read is the most recent one, draft included, so a provider sees
  # the copy their course page is showing them rather than an older published
  # version sitting beneath an unpublished edit.
  #
  # Two sections changed shape for the 2027 cycle, and a cycle is fixed for the
  # whole file, so their columns are chosen once rather than carried in every
  # file and left blank in half of them.
  #
  # Each text column is headed with the question Publish asks rather than a
  # short label, so a provider can match a column to the box they type into.
  # The wording is repeated here rather than read from the form's locale keys:
  # a CSV header is an interface of its own, and renaming a column should be a
  # deliberate change rather than a side effect of reworking a form.
  class FullCourseInformationList
    include ActionView::Helpers::NumberHelper
    include Publish::CourseInterviewLocationHelper
    include CourseColumns

    # The last cycle before salary_details gave way to salary_fee_details and
    # salaried courses began stating the school experience they ask for.
    FINAL_LEGACY_SECTIONS_CYCLE = 2026

    HEADERS_BEFORE_SALARY = [
      "Course name",
      "Course code",
      "Accredited provider",
      "Status",
      "Age range",
      "Fee or salary",
      "Qualification",
      "Study mode",
      "Start date",
      "Course length",
      "UK fee",
      "Non-UK fee",
      "When are the fees due? Is there a payment schedule? (optional)",
      "Are there any additional fees or costs? (optional)",
      "Does your organisation offer any financial support? (optional)",
    ].freeze

    HEADERS_AFTER_SCHOOL_EXPERIENCE = [
      "How do you decide which schools to place trainees in?",
      "How much time will they spend in each school?",
      "Where will theoretical training take place? (optional)",
      "How much time will they spend in theoretical training? (optional)",
      "What will trainees do while in their placement schools?",
      "How will they be supported and mentored? (optional)",
      "What will trainees do during their theoretical training?",
      "How will they be assessed? (optional)",
      "What is the interview process? (optional)",
      "Where will the interviews take place? (optional)",
    ].freeze

    def initialize(provider:)
      @provider = provider
    end

    def data
      BYTE_ORDER_MARK + CSV.generate(headers:, write_headers: true) do |csv|
        courses.each { |course| csv << row(course) }
      end
    end

    def filename
      "full-course-information-#{provider.provider_code}-#{Time.zone.today}.csv"
    end

  private

    attr_reader :provider

    def headers
      HEADERS_BEFORE_SALARY + [salary_header] + school_experience_headers + HEADERS_AFTER_SCHOOL_EXPERIENCE
    end

    def row(course)
      enrichment = latest_enrichment(course)

      values_before_salary(course, enrichment) +
        [salary_value(enrichment)] +
        school_experience_values(course) +
        values_after_school_experience(enrichment)
    end

    def values_before_salary(course, enrichment)
      [
        course.name,
        course.course_code,
        accredited_provider(course),
        status(course),
        age_range(course),
        I18n.t("publish.courses.course_table.funding.#{course.funding}"),
        course.qualifications_summary,
        course.study_mode_description.capitalize,
        start_date(course),
        course_length(enrichment&.course_length),
        fee(course, enrichment&.fee_uk_eu),
        fee(course, enrichment&.fee_international),
        enrichment&.fee_schedule,
        enrichment&.additional_fees,
        enrichment&.financial_support,
      ]
    end

    def values_after_school_experience(enrichment)
      [
        enrichment&.placement_selection_criteria,
        enrichment&.duration_per_school,
        enrichment&.theoretical_training_location,
        enrichment&.theoretical_training_duration,
        enrichment&.placement_school_activities,
        enrichment&.support_and_mentorship,
        enrichment&.theoretical_training_activities,
        enrichment&.assessment_methods,
        enrichment&.interview_process,
        display_interview_location(enrichment&.interview_location),
      ]
    end

    # Salaried and apprenticeship courses charge no fees, so Publish never shows
    # the fee rows for them. An amount can still be sitting on the enrichment
    # from before the course changed funding, and printing it would tell a
    # provider they charge a fee they do not.
    def fee(course, amount)
      number_to_currency(amount) if course.fee_based?
    end

    def salary_header
      if current_sections?
        "Give details about any fees or other costs that the trainee might have to pay (optional)"
      else
        "Salary"
      end
    end

    def salary_value(enrichment)
      current_sections? ? enrichment&.salary_fee_details : enrichment&.salary_details
    end

    def school_experience_headers
      current_sections? ? ["What school experience are you looking for?"] : []
    end

    def school_experience_values(course)
      return [] unless current_sections?

      [school_experience(course)]
    end

    # Only salaried and apprenticeship courses are asked the question, so a fee
    # course leaves the cell empty rather than claiming it asks for none.
    def school_experience(course)
      case course.school_experience_required
      when true then course.school_experience_required_content
      when false then "Not required"
      end
    end

    def current_sections?
      provider.recruitment_cycle.after?(FINAL_LEGACY_SECTIONS_CYCLE)
    end

    # Matches CourseEnrichment.most_recent, which backs Course#latest_enrichment,
    # but reads the preloaded rows rather than querying once per course.
    def latest_enrichment(course)
      course.enrichments.max_by { |enrichment| [enrichment.created_at, enrichment.id] }
    end

    def courses
      Publish::Courses::Query.call(provider:).preload(:enrichments)
    end

    def accredited_provider(course)
      code = course.accredited_provider_code
      return provider.provider_name if code.blank? || code == provider.provider_code

      course[:group_name] || code
    end
  end
end
