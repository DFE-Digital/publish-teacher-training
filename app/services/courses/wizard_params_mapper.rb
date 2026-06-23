# frozen_string_literal: true

module Courses
  class WizardParamsMapper
    include ServicePattern

    attr_reader :wizard, :state_store

    def initialize(wizard:)
      @wizard = wizard
      @state_store = wizard.state_store
    end

    def call
      ActionController::Parameters.new(mapped_params).permit!
    end

  private

    def mapped_params
      {
        "level" => state_store.level,
        "is_send" => state_store.is_send,
        "master_subject_id" => master_subject_id,
        "subordinate_subject_id" => state_store.subordinate_subject_id,
        "subjects_ids" => subjects_ids,
        "age_range_in_years" => mapped_age_range_in_years,
        "qualification" => state_store.qualification,
        "funding" => mapped_funding,
        "study_mode" => mapped_study_mode,
        "sites_ids" => Array(state_store.site_ids).compact_blank,
        "study_sites_ids" => mapped_study_sites_ids,
        "accredited_provider_code" => state_store.accredited_provider_code,
        "start_date" => state_store.start_date,
        "campaign_name" => state_store.campaign_name,
        "can_sponsor_student_visa" => state_store.can_sponsor_student_visa,
        "can_sponsor_skilled_worker_visa" => state_store.can_sponsor_skilled_worker_visa,
        "visa_sponsorship_application_deadline_required" => state_store.visa_sponsorship_application_deadline_required,
      }.compact.merge(mapped_visa_deadline_params)
    end

    def master_subject_id
      return if state_store.further_education_level?

      state_store.primary_level? ? state_store.primary_master_subject_id : state_store.secondary_master_subject_id
    end

    def subjects_ids
      return [] if state_store.further_education_level?

      [
        state_store.primary_master_subject_id,
        state_store.secondary_master_subject_id,
        state_store.subordinate_subject_id,
        *selected_specialism_subject_ids,
      ].compact_blank.uniq
    end

    def selected_specialism_subject_ids
      specialism_ids = []

      if state_store.modern_languages_specialisms?
        specialism_ids.concat(Array(state_store.language_ids))
      end

      if state_store.design_technology_specialisms?
        specialism_ids.concat(Array(state_store.design_technology_ids))
      end

      specialism_ids
    end

    def mapped_age_range_in_years
      return state_store.age_range_in_years unless state_store.age_range_in_years == "other"
      return state_store.age_range_in_years if state_store.course_age_range_in_years_other_from.blank? || state_store.course_age_range_in_years_other_to.blank?

      "#{state_store.course_age_range_in_years_other_from}_to_#{state_store.course_age_range_in_years_other_to}"
    end

    def mapped_funding
      return "apprenticeship" if state_store.undergraduate_degree_with_qts? && state_store.funding_type.blank?

      state_store.funding_type
    end

    def mapped_study_mode
      patterns = Array(state_store.study_pattern).compact_blank
      return patterns if patterns.present?
      return nil if state_store.undergraduate_degree_with_qts?

      []
    end

    def mapped_study_sites_ids
      return nil if state_store.study_sites_ids.nil?

      Array(state_store.study_sites_ids).compact_blank
    end

    def mapped_visa_deadline_params
      deadline = state_store.visa_sponsorship_application_deadline_at
      return {} if deadline.blank?

      year, month, day = visa_deadline_parts(deadline)
      return {} if [year, month, day].any?(&:blank?)

      {
        "visa_sponsorship_application_deadline_at(1i)" => year.to_s,
        "visa_sponsorship_application_deadline_at(2i)" => month.to_s,
        "visa_sponsorship_application_deadline_at(3i)" => day.to_s,
      }
    end

    def visa_deadline_parts(deadline)
      if deadline.respond_to?(:year) && deadline.respond_to?(:month) && deadline.respond_to?(:day)
        [deadline.year, deadline.month, deadline.day]
      elsif deadline.is_a?(Hash)
        [deadline[:year] || deadline["year"], deadline[:month] || deadline["month"], deadline[:day] || deadline["day"]]
      else
        [nil, nil, nil]
      end
    end
  end
end
