# frozen_string_literal: true

class CourseDecorator < ApplicationDecorator
  include ActiveSupport::NumberHelper

  delegate_all

  LANGUAGE_SUBJECT_CODES = %w[Q3 A0 15 16 17 18 19 20 21 22].freeze

  def name_and_code
    "#{object.name} (#{object.course_code})"
  end

  def modern_languages_other_id
    '24'
  end

  def vacancies
    content = object.has_vacancies? ? 'Yes' : 'No'
    content += " (#{edit_vacancy_link})" unless object.is_withdrawn?
    content.html_safe
  end

  def find_url(provider = object.provider)
    h.search_ui_course_page_url(provider_code: provider.provider_code, course_code: object.course_code)
  end

  def on_find(provider = object.provider)
    if object.findable?
      if current_cycle_and_open?
        h.govuk_link_to('Yes - view online', h.search_ui_course_page_url(provider_code: provider.provider_code, course_code: object.course_code))
      else
        "No - live on #{l(Settings.next_cycle_open_date.to_date, format: :govuk_short)}"
      end
    else
      not_on_find
    end
  end

  def open_or_closed_for_applications
    object.open_for_applications? ? 'Open' : 'Closed'
  end

  def outcome
    I18n.t("edit_options.qualifications.#{object.qualification}.label")
  end

  def find_outcome
    I18n.t("find.qualifications.#{object.qualification}")
  end

  def is_send?
    object.is_send? ? 'Yes' : 'No'
  end

  def funding
    {
      'salary' => 'Salary',
      'apprenticeship' => 'Teaching apprenticeship - with salary',
      'fee' => 'Fee paying - no salary'
    }[object.funding_type]
  end

  def subject_name
    if object.subjects.size == 1
      object.subjects.first.subject_name
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
      transformed_subjects = subjects.map { |subject| LANGUAGE_SUBJECT_CODES.include?(subject.subject_code) ? subject.subject_name : subject.subject_name.downcase }
      "#{transformed_subjects.first} with #{transformed_subjects.second}"
    else
      object.name.gsub('Modern Languages', 'modern languages')
    end
  end

  def has_scholarship_and_bursary?
    object.has_bursary? && object.has_scholarship?
  end

  def bursary_first_line_ending
    if bursary_requirements.count > 1
      ':'
    else
      "#{bursary_requirements.first}."
    end
  end

  def bursary_requirements
    requirements = ['a degree of 2:2 or above in any subject']

    if object.subjects.any? { |subject| subject.subject_name.downcase == 'primary with mathematics' }
      mathematics_requirement = 'at least grade B in maths A-level (or an equivalent)'
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
    find_max_funding_for('bursary_amount')
  end

  def scholarship_amount
    find_max_funding_for('scholarship')
  end

  def salaried?
    object.funding_type == 'salary' || object.funding_type == 'apprenticeship'
  end

  def apprenticeship?
    object.funding_type == 'apprenticeship'
  end

  def apprenticeship
    object.funding_type.to_s == 'apprenticeship' ? 'Yes' : 'No'
  end

  def sorted_subjects
    object.subjects.map(&:subject_name).sort.join('<br>').html_safe
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
    when 'OneYear'
      '1 year'
    when 'TwoYears'
      'Up to 2 years'
    else
      course_length.to_s
    end
  end

  def other_course_length?
    %w[OneYear TwoYears].exclude?(course_length) && !course_length.nil?
  end

  def other_age_range?
    options = object.edit_course_options['age_range_in_years']
    options.exclude?(course.age_range_in_years)
  end

  def alphabetically_sorted_sites
    object.sites.sort_by(&:location_name)
  end

  def preview_site_statuses
    object.site_statuses.new_or_running.sort_by { |status| status.site.location_name }
  end

  def has_site?(site)
    !course.sites.nil? && object.sites.any? { |s| s.id == site.id }
  end

  # rubocop:disable Lint/DuplicateBranch: Duplicate branch body detected
  def funding_option
    if salaried?
      'Salary'
    elsif excluded_from_bursary?
      # Duplicate branch body detected
      'Student finance if you’re eligible'
    elsif has_scholarship_and_bursary? && bursary_and_scholarship_flag_active_or_preview?
      'Scholarships or bursaries, as well as student finance, are available if you’re eligible'
    elsif has_bursary? && bursary_and_scholarship_flag_active_or_preview?
      'Bursaries and student finance are available if you’re eligible'
    else
      # Duplicate branch body detected
      'Student finance if you’re eligible'
    end
  end
  # rubocop:enable Lint/DuplicateBranch: Duplicate branch body detected

  def current_cycle?
    course.recruitment_cycle.year.to_i == Settings.current_recruitment_cycle_year
  end

  def current_cycle_and_open?
    current_cycle? && FeatureService.enabled?('rollover.has_current_cycle_started?')
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
  alias year_range cycle_range

  def age_range
    if object.age_range_in_years.present?
      I18n.t("edit_options.age_range_in_years.#{object.age_range_in_years}.label", default: object.age_range_in_years.humanize)
    else
      "<span class='app-!-colour-muted'>Unknown</span>".html_safe
    end
  end

  def applications_open_from_message_for(recruitment_cycle)
    if current_cycle?
      'As soon as the course is on Find - recommended'
    else
      year = recruitment_cycle.year.to_i
      day_month = recruitment_cycle.application_start_date.strftime('%-d %B')
      "On #{day_month} when applications for the #{year - 1} to #{year} cycle open"
    end
  end

  def selectable_subjects
    edit_course_options['subjects'].map { |subject| [subject.attributes['subject_name'], subject['id']] }
  end

  def selected_subject_ids
    selectable_subject_ids = course.subjects.pluck('id')
    selected_subject_ids = subjects.map(&:id)

    selectable_subject_ids & selected_subject_ids
  end

  def subordinate_subject_id
    selected_subject_ids - [master_subject_id] if master_subject_id
  end

  def subject_present?(subject_to_find)
    subjects.any? do |course_subject|
      course_subject.id == subject_to_find.id
    end
  end

  def return_start_date
    if FeatureService.enabled?('rollover.can_edit_current_and_next_cycles')
      start_date.presence || "September #{Settings.current_recruitment_cycle_year + 1}"
    else
      start_date.presence || "September #{Settings.current_recruitment_cycle_year}"
    end
  end

  def placements_heading
    if further_education?
      'Teaching placements'
    else
      'School placements'
    end
  end

  def further_education?
    level == 'further_education' && subjects.any? { |s| s.subject_name == 'Further education' || s.subject_code = '41' }
  end

  def subject_page_title
    if level == 'primary' || level == 'secondary'
      'Subject'
    else
      'Pick a subject'
    end
  end

  def accept_gcse_equivalency?
    object.accept_gcse_equivalency
  end

  def has_fees?
    object.funding_type.match?(/fee/)
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

  def interview_process
    object.enrichment_attribute(:interview_process)
  end

  def how_school_placements_work
    object.enrichment_attribute(:how_school_placements_work)
  end

  def fee_uk_eu
    object.enrichment_attribute(:fee_uk_eu)
  end

  def fee_international
    object.enrichment_attribute(:fee_international)
  end

  def fee_details
    object.enrichment_attribute(:fee_details)
  end

  def financial_support
    object.enrichment_attribute(:financial_support)
  end

  def financial_incentive_details
    financial_incentive = object.financial_incentives.first
    bursary_amount = number_to_currency(financial_incentive&.bursary_amount)
    scholarship = number_to_currency(financial_incentive&.scholarship)

    return I18n.t('components.course.financial_incentives.not_yet_available') if (course.recruitment_cycle_year.to_i > Settings.current_recruitment_cycle_year) || !FeatureFlag.active?(:bursaries_and_scholarships_announced)
    return I18n.t('components.course.financial_incentives.none') if financial_incentive.nil?

    return I18n.t('components.course.financial_incentives.bursary_and_scholarship', scholarship:, bursary_amount:) if bursary_amount.present? && scholarship.present?

    I18n.t('components.course.financial_incentives.bursary', amount: bursary_amount)
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

  def about_accrediting_body
    object.accrediting_provider_description
  end

  def has_physical_education_subject?
    subjects.map(&:subject_name).include?('Physical education')
  end

  private

  def not_on_find
    if object.new_and_not_running?
      'No - still in draft'
    elsif object.is_withdrawn?
      'No - withdrawn'
    else
      'No'
    end
  end

  def edit_vacancy_link
    h.govuk_link_to(h.vacancies_publish_provider_recruitment_cycle_course_path(object.provider_code, object.recruitment_cycle.year, object.course_code)) do
      h.raw("Change<span class=\"govuk-visually-hidden\"> vacancies for #{name_and_code}</span>")
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
      /^Physical/
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
    subjects.first.subject_name
  end

  def modern_languages_other?
    subjects.any? { |subject| subject.subject_code == modern_languages_other_id }
  end

  def main_subject_is_modern_languages?
    main_subject.id == SecondarySubject.modern_languages.id
  end

  def main_subject
    Subject.find(course.master_subject_id)
  end

  def additional_subjects
    object.subjects.reject { |subject| subject.id == main_subject.id }
  end

  def format_name(subjects)
    subjects.map(&:subject_name).join('<br>').html_safe
  end
end
