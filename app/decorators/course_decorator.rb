# frozen_string_literal: true

class CourseDecorator < ApplicationDecorator
  include ActiveSupport::NumberHelper
  include ActionView::Helpers::TranslationHelper

  delegate_all

  LANGUAGE_SUBJECT_CODES = %w[Q3 A0 15 16 17 18 19 20 21 22].freeze

  def sites_ids
    object.site_ids.compact_blank
  end

  def study_sites_ids
    object.study_site_ids.compact_blank
  end

  def modern_languages_other_id
    "24"
  end

  def find_url(provider = object.provider)
    h.find_course_url(provider.provider_code, object.course_code)
  end

  def description
    object.description.to_s.sub("PGCE with QTS", "QTS with PGCE")
  end

  def on_find(provider = object.provider)
    if object.findable?
      if current_cycle_and_open?
        h.govuk_link_to("View live course", h.find_course_url(provider.provider_code, object.course_code))
      else
        "No - live on #{l(Settings.next_cycle_open_date.to_date, format: :govuk_short)}"
      end
    else
      not_on_find
    end
  end

  def open_or_closed_for_applications
    object.open_for_applications? ? "Open" : "Closed"
  end

  def a_level_change_path
    return if object.is_withdrawn?

    if object.a_level_subject_requirements.present?
      h.publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
        object.provider.provider_code,
        object.provider.recruitment_cycle_year,
        object.course_code,
      )
    else
      h.publish_provider_recruitment_cycle_course_a_levels_what_a_level_is_required_path(
        object.provider.provider_code,
        object.provider.recruitment_cycle_year,
        object.course_code,
      )
    end
  end

  def outcome
    I18n.t("edit_options.qualifications.#{object.qualification}.label")
  end

  def find_outcome
    I18n.t("find.qualifications.#{object.qualification}")
  end

  def is_send?
    object.is_send? ? "Yes" : "No"
  end

  def subject_name
    if object.subjects.size == 1
      object.course_subjects.first.subject.subject_name
    else
      object.name
    end
  end

  def computed_subject_name_or_names
    if (number_of_subjects == 1 || modern_languages_other?) && LANGUAGE_SUBJECT_CODES.include?(subjects.first.subject_code)
      first_subject_name
    elsif (number_of_subjects == 1 || modern_languages_other?) && LANGUAGE_SUBJECT_CODES.exclude?(subjects.first.subject_code)
      first_subject_name.downcase
    elsif number_of_subjects == 2
      transformed_subjects = course_subjects.map { |cs| LANGUAGE_SUBJECT_CODES.include?(cs.subject.subject_code) ? cs.subject.subject_name : cs.subject.subject_name.downcase }
      "#{transformed_subjects.first} with #{transformed_subjects.second}"
    else
      object.name.gsub("Modern Languages", "modern languages")
    end
  end

  def has_scholarship_and_bursary?
    object.has_bursary? && object.has_scholarship?
  end

  def bursary_first_line_ending
    if bursary_requirements.count > 1
      ":"
    else
      "#{bursary_requirements.first}."
    end
  end

  def bursary_requirements
    requirements = ["a degree of 2:2 or above in any subject"]

    if object.course_subjects.any? { |subject| subject.subject.subject_name.downcase == "primary with mathematics" }
      mathematics_requirement = "at least grade B in maths A-level (or an equivalent)"
      requirements.push(mathematics_requirement)
    end

    requirements
  end

  def bursary_only?
    object.has_bursary? && !object.has_scholarship?
  end

  def excluded_from_bursary?
    object.subjects.present? &&
      # incorrect bursary eligibility only shows up on courses with 2 subjects
      object.subjects.count == 2 &&
      has_excluded_course_name?
  end

  def bursary_amount
    find_max_funding_for("bursary_amount")
  end

  def scholarship_amount
    find_max_funding_for("scholarship")
  end

  def salaried?
    object.funding.in?(%w[salary apprenticeship])
  end

  def apprenticeship?
    object.funding.to_s == "apprenticeship"
  end

  def apprenticeship
    apprenticeship? ? "Yes" : "No"
  end

  def sorted_subjects
    object.course_subjects.map { |cs| cs.subject.subject_name }.join("<br>").html_safe
  end

  def chosen_subjects
    return sorted_subjects if master_subject_nil?

    if main_subject_is_modern_languages?
      format_name(modern_language_subjects.to_a.push(additional_subjects.sort_by { |x| [x.type, x.subject_name] }).flatten.uniq.unshift(main_subject))
    elsif !main_subject_is_modern_languages? && modern_languages_subjects.present?
      format_name(additional_subjects.push(modern_language_subjects.to_a).flatten.uniq.unshift(main_subject))
    else
      format_name(additional_subjects.unshift(main_subject))
    end
  end

  def length
    case course_length.to_s
    when "OneYear"
      "1 year"
    when "TwoYears"
      "Up to 2 years"
    else
      course_length.to_s
    end
  end

  def course_length_with_study_mode
    [
      length,
      study_mode&.humanize&.downcase,
    ].compact_blank.join(" - ")
  end

  def other_course_length?
    %w[OneYear TwoYears].exclude?(course_length) && !course_length.nil?
  end

  def other_age_range?
    options = object.edit_course_options["age_range_in_years"]
    options.exclude?(course.age_range_in_years)
  end

  def alphabetically_sorted_sites
    object.sites.sort_by(&:location_name)
  end

  def alphabetically_sorted_study_sites
    object.study_sites.sort_by(&:location_name)
  end

  def preview_site_statuses
    object.site_statuses.new_or_running.sort_by { |status| status.site.location_name }
  end

  def has_site?(site)
    !course.sites.nil? && object.sites.any? { |s| s.id == site.id }
  end

  def funding_option
    return if salaried?

    if excluded_from_bursary?
      # Duplicate branch body detected
      "Student loans if you’re eligible"
    elsif has_scholarship_and_bursary? && bursary_and_scholarship_flag_active_or_preview?
      "Scholarships or bursaries, as well as student loans, are available if you’re eligible"
    elsif has_bursary? && bursary_and_scholarship_flag_active_or_preview?
      "Bursaries and student loans are available if you’re eligible"
    else
      # Duplicate branch body detected
      "Student loans are available if you’re eligible"
    end
  end

  def current_cycle?
    course.recruitment_cycle.year.to_i == Settings.current_recruitment_cycle_year
  end

  def current_cycle_and_open?
    current_cycle? && FeatureService.enabled?("rollover.has_current_cycle_started?")
  end

  def next_cycle?
    course.recruitment_cycle.year.to_i == Settings.current_recruitment_cycle_year + 1
  end

  def use_financial_support_placeholder?
    next_cycle?
  end

  def cycle_range
    "#{course.recruitment_cycle.year} to #{course.recruitment_cycle.year.to_i + 1}"
  end
  alias_method :year_range, :cycle_range

  def age_range
    I18n.t("edit_options.age_range_in_years.#{object.age_range_in_years}.label", default: object.age_range_in_years.humanize)
  end

  def age_range_in_years_and_level
    return if age_range_in_years.blank?

    if secondary_course?
      "#{age_range_in_years.humanize} - #{level}"
    else
      age_range_in_years.humanize
    end
  end

  def applications_open_first_label(recruitment_cycle)
    if current_cycle?
      "As soon as the course is published - recommended"
    else
      application_start_date = recruitment_cycle.application_start_date.strftime("%-d %B %Y")
      "On #{application_start_date} when Apply opens - recommended"
    end
  end

  def selectable_subjects
    edit_course_options["subjects"].map { |subject| [subject.attributes["subject_name"], subject["id"]] }
  end

  def selected_subject_ids
    selectable_subject_ids = course.subjects.map(&:id)
    selected_subject_ids = subjects.map(&:id)

    selectable_subject_ids & selected_subject_ids
  end

  def subject_present?(subject_to_find)
    course_subjects.any? do |course_subject|
      course_subject.subject.id == subject_to_find.id
    end
  end

  def placements_heading
    CourseEnrichment.human_attribute_name("how_school_placements_work")
  end

  def length_and_fees_or_salary_heading
    heading = has_fees? ? "course_length_and_fees_heading" : "course_length_and_salary_heading"

    I18n.t("publish.providers.courses.description_content.#{heading}")
  end

  def further_education?
    level == "further_education" && subjects.any? { |s| s.subject_name == "Further education" || s.subject_code = "41" }
  end

  def subject_page_title
    if level.in?(%w[primary secondary])
      "Subject"
    else
      "Pick a subject"
    end
  end

  def accept_gcse_equivalency?
    object.accept_gcse_equivalency
  end

  def has_fees?
    object.funding.match?(/fee/)
  end

  def is_further_education?
    object.level.match?(/further_education/)
  end

  def degree_section_complete?
    object.degree_grade.present?
  end

  def gcse_section_complete?
    !object.accept_pending_gcse.nil? && !object.accept_gcse_equivalency.nil?
  end

  def about_course
    object.enrichment_attribute(:about_course)
  end

  def placement_school_activities
    object.enrichment_attribute(:placement_school_activities)
  end

  def support_and_mentorship
    object.enrichment_attribute(:support_and_mentorship)
  end

  def interview_process
    object.enrichment_attribute(:interview_process)
  end

  def interview_location
    object.enrichment_attribute(:interview_location)
  end

  def how_school_placements_work
    object.enrichment_attribute(:how_school_placements_work)
  end

  def theoretical_training_activities
    object.enrichment_attribute(:theoretical_training_activities)
  end

  def assessment_methods
    object.enrichment_attribute(:assessment_methods)
  end

  %i[placement_selection_criteria
     duration_per_school
     theoretical_training_location
     theoretical_training_duration].each do |col|
    define_method col do
      object.enrichment_attribute(col).to_s
    end
  end

  def where_you_will_train
    [placement_selection_criteria,
     duration_per_school,
     theoretical_training_location,
     theoretical_training_duration]
  end

  def fee_uk_eu
    object.enrichment_attribute(:fee_uk_eu)
  end

  def fee_international
    object.enrichment_attribute(:fee_international)
  end

  def additional_fees
    object.enrichment_attribute(:additional_fees)
  end

  def fee_schedule
    object.enrichment_attribute(:fee_schedule)
  end

  def fee_details
    object.enrichment_attribute(:fee_details)
  end

  def financial_support
    object.enrichment_attribute(:financial_support)
  end

  def published_about_course
    return unless current_published_enrichment

    current_published_enrichment[:about_course]
  end

  def placement_selection_criteria
    return unless current_published_enrichment

    current_published_enrichment[:placement_selection_criteria]
  end

  def published_placement_school_activities
    return unless current_published_enrichment

    current_published_enrichment[:placement_school_activities]
  end

  def published_support_and_mentorship
    return unless current_published_enrichment

    current_published_enrichment[:support_and_mentorship]
  end

  def published_interview_process
    return unless current_published_enrichment

    current_published_enrichment[:interview_process]
  end

  def published_interview_location
    return unless current_published_enrichment

    current_published_enrichment[:interview_location]
  end

  def published_how_school_placements_work
    return unless current_published_enrichment

    current_published_enrichment[:how_school_placements_work]
  end

  def train_with_disability
    return unless current_published_enrichment

    current_published_enrichment[:train_with_disability]
  end

  def published_fee_uk_eu
    return unless current_published_enrichment

    current_published_enrichment[:fee_uk_eu]
  end

  def published_fee_international
    return unless current_published_enrichment

    current_published_enrichment[:fee_international]
  end

  def published_fee_details
    return unless current_published_enrichment

    current_published_enrichment[:fee_details]
  end

  def published_financial_support
    return unless current_published_enrichment

    current_published_enrichment[:financial_support]
  end

  def financial_incentive_details
    financial_incentive = object.financial_incentives.first
    bursary_amount = number_to_currency(financial_incentive&.bursary_amount)
    scholarship = number_to_currency(financial_incentive&.scholarship)

    return I18n.t("components.course.financial_incentives.not_yet_available") if (course.recruitment_cycle_year.to_i > Settings.current_recruitment_cycle_year) || !FeatureFlag.active?(:bursaries_and_scholarships_announced)
    return I18n.t("components.course.financial_incentives.none") if financial_incentive.nil?

    return I18n.t("components.course.financial_incentives.bursary_and_scholarship", scholarship:, bursary_amount:) if bursary_amount.present? && scholarship.present?

    I18n.t("components.course.financial_incentives.bursary", amount: bursary_amount)
  end

  def salary_details
    object.enrichment_attribute(:salary_details)
  end

  def personal_qualities
    object.enrichment_attribute(:personal_qualities)
  end

  def other_requirements
    object.enrichment_attribute(:other_requirements)
  end

  def course_length
    object.enrichment_attribute(:course_length)
  end

  def about_accrediting_provider
    object.ratifying_provider_description
  end

  def has_physical_education_subject?
    subjects.map(&:subject_name).include?("Physical education")
  end

  def cannot_change_funding_type?
    is_published? || is_withdrawn? || teacher_degree_apprenticeship?
  end

  def cannot_change_study_mode?
    is_withdrawn? || teacher_degree_apprenticeship?
  end

  def cannot_change_course_length?
    teacher_degree_apprenticeship? || is_withdrawn?
  end

  def cannot_change_skilled_worker_visa?
    is_withdrawn? || teacher_degree_apprenticeship?
  end

  def show_skilled_worker_visa_row?
    school_direct_salaried_training_programme? ||
      pg_teaching_apprenticeship? ||
      teacher_degree_apprenticeship?
  end

  def show_sponsorship_deadline_required_row?
    visa_sponsorship.in?(%i[can_sponsor_student_visa can_sponsor_skilled_worker_visa])
  end

  def show_sponsorship_deadline_date_row?
    show_sponsorship_deadline_required_row? &&
      visa_sponsorship_application_deadline_at.respond_to?(:to_fs)
  end

  def show_degree_requirements_row?
    !teacher_degree_apprenticeship?
  end

  def visa_sponsorship_deadline_required
    visa_sponsorship_application_deadline_at.respond_to?(:to_fs) ? "Yes" : "No"
  end

  def equivalent_qualification
    if two_one? || two_two?
      translate("shared.decorators.course.above_or_equivalent_qualification_html")
    elsif third_class?
      translate("shared.decorators.course.third_or_above_html")
    else
      translate("shared.decorators.course.equivalent_qualification_html")
    end
  end

  def degree_grade_content
    degree_grade_hash = {
      "two_one" => I18n.t("shared.decorators.course.two_one_degree"),
      "two_two" => I18n.t("shared.decorators.course.two_two_degree"),
      "third_class" => I18n.t("shared.decorators.course.third_class_degree"),
      "not_required" => I18n.t("shared.decorators.course.degree_not_required"),
    }

    degree_grade_hash[degree_grade]
  end

  def course_fee_content
    safe_join(
      [
        bold_tag(number_to_currency(fee_uk_eu)),
        formatted_uk_eu_fee_label,
        tag.br,
        bold_tag(number_to_currency(fee_international)),
        formatted_international_fee_label,
      ],
    )
  end

  def no_fee?
    !object.fee?
  end

  def training_locations?
    published_how_school_placements_work.present? ||
      study_sites.any? ||
      site_statuses.map(&:site).uniq.many?
  end

private

  def not_on_find
    if object.new_and_not_running?
      "Still in draft"
    elsif object.is_withdrawn?
      "No - withdrawn"
    else
      "No"
    end
  end

  def find_max_funding_for(attribute)
    subject_funding_amounts = object.subjects.map do |s|
      s.financial_incentive.public_send(attribute.to_sym).to_i if s.financial_incentive.present? && s.financial_incentive.attributes[attribute].present?
    end

    subject_funding_amounts.compact.max.to_s
  end

  def has_excluded_course_name?
    exclusions = [
      /^Drama/,
      /^Media Studies/,
      /^PE/,
      /^Physical/,
    ]
    # We only care about course with a name matching the pattern 'Foo with bar'
    # We don't care about courses matching the pattern 'Foo and bar'
    return false unless /with/.match?(object.name)

    exclusions.any? { |e| e.match?(object.name) }
  end

  def bursary_and_scholarship_flag_active_or_preview?
    FeatureFlag.active?(:bursaries_and_scholarships_announced)
  end

  def number_of_subjects
    subjects.size
  end

  def first_subject_name
    course_subjects.first.subject.subject_name
  end

  def modern_languages_other?
    subjects.any? { |subject| subject.subject_code == modern_languages_other_id }
  end

  def main_subject_is_modern_languages?
    main_subject.id == SecondarySubject.modern_languages.id
  end

  def main_subject
    @main_subject ||= Subject.find(course.master_subject_id)
  end

  def additional_subjects
    object.course_subjects.reject { |subject| subject.subject_id == main_subject.id }.map(&:subject)
  end

  def format_name(subjects)
    subjects.map(&:subject_name).join("<br>").html_safe
  end

  def formatted_uk_eu_fee_label
    return if fee_uk_eu.blank?

    " #{I18n.t('find.courses.summary_component.view.for_uk_citizens')}"
  end

  def formatted_international_fee_label
    return if fee_international.blank?

    " #{I18n.t('find.courses.summary_component.view.for_non_uk_citizens')}"
  end

  def bold_tag(value)
    return if value.blank?

    tag.b(value)
  end
end
