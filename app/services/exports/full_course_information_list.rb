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
  # Some columns only ever apply to part of the estate: two sections changed
  # shape for the 2027 cycle, and only teacher degree apprenticeships are asked
  # about A levels. A cycle and a provider are both fixed for a whole file, so
  # those columns are chosen once when the file is built rather than carried
  # everywhere and left blank in most of it.
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

    DEGREE_HEADERS = [
      "What is the minimum degree classification you require?",
      "Degree subject requirements",
    ].freeze

    # Only teacher degree apprenticeship courses are asked about A levels. Both
    # this and the GCSE section label their free text box "Details about
    # equivalency tests you offer or accept", so each says which it means: a
    # repeated header collapses the columns together when the CSV is parsed.
    A_LEVEL_HEADERS = [
      "What A level or equivalent qualification is required?",
      "Will you consider candidates with pending A levels?",
      "Will you consider candidates who need to take an equivalency test for their A levels?",
      "Details about equivalency tests you offer or accept (A levels)",
    ].freeze

    GCSE_HEADERS = [
      "GCSEs required",
      "Will you consider candidates with pending GCSEs?",
      "Will you consider candidates who need to take an equivalency test in English, maths or science?",
      "Which subjects will you accept equivalency tests in?",
      "Details about equivalency tests you offer or accept (GCSEs)",
    ].freeze

    GCSE_EQUIVALENCY_SUBJECTS = {
      "English" => :accept_english_gcse_equivalency,
      "Maths" => :accept_maths_gcse_equivalency,
      "Science" => :accept_science_gcse_equivalency,
    }.freeze

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
      HEADERS_BEFORE_SALARY +
        [salary_header] +
        school_experience_headers +
        DEGREE_HEADERS +
        a_level_headers +
        GCSE_HEADERS +
        HEADERS_AFTER_SCHOOL_EXPERIENCE
    end

    def row(course)
      enrichment = latest_enrichment(course)

      values_before_salary(course, enrichment) +
        [salary_value(enrichment)] +
        school_experience_values(course) +
        degree_values(course) +
        a_level_values(course) +
        gcse_values(course) +
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

    # The grade is a choice rather than free text, so it reads back as the
    # sentence the course page shows rather than the stored enum value.
    def degree_values(course)
      [
        DegreeRowContent::DEGREE_GRADE_MAPPING[course.degree_grade],
        course.degree_subject_requirements,
      ]
    end

    def a_level_headers
      any_teacher_degree_apprenticeship? ? A_LEVEL_HEADERS : []
    end

    def a_level_values(course)
      return [] unless any_teacher_degree_apprenticeship?
      return Array.new(A_LEVEL_HEADERS.length) unless course.teacher_degree_apprenticeship?

      [
        a_level_subject_requirements(course),
        yes_or_no(course.accept_pending_a_level),
        yes_or_no(course.accept_a_level_equivalency),
        course.additional_a_level_equivalencies,
      ]
    end

    # One requirement to a line, worded as the course page words them, so a
    # subject and its minimum grade stay together in a single cell.
    def a_level_subject_requirements(course)
      requirements = course.a_level_subject_requirements.map do |requirement|
        ALevelSubjectRequirementRowComponent.new(requirement).row_value
      end

      requirements.join("\n").presence
    end

    def gcse_values(course)
      [
        required_gcses(course),
        yes_or_no(course.accept_pending_gcse),
        yes_or_no(course.accept_gcse_equivalency),
        gcse_equivalency_subjects(course),
        course.additional_gcse_equivalencies,
      ]
    end

    # Derived from the course level and the provider's required grade rather
    # than written by anyone, but it is the first thing the GCSE row shows, so
    # the file would not be a whole picture of the section without it.
    def required_gcses(course)
      subjects = case course.level
                 when "primary" then "English, maths and science"
                 when "secondary" then "English and maths"
                 end
      return if subjects.blank?

      "Grade #{course.gcse_grade_required} (C) or above in #{subjects}, or equivalent qualification"
    end

    def gcse_equivalency_subjects(course)
      GCSE_EQUIVALENCY_SUBJECTS
        .select { |_subject, attribute| course.public_send(attribute).present? }
        .keys
        .to_sentence
        .presence
    end

    def yes_or_no(answer)
      return if answer.nil?

      answer ? "Yes" : "No"
    end

    def any_teacher_degree_apprenticeship?
      return @any_teacher_degree_apprenticeship if defined?(@any_teacher_degree_apprenticeship)

      @any_teacher_degree_apprenticeship = provider.courses.teacher_degree_apprenticeship.exists?
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
