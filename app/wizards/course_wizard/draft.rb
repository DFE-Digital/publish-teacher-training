# frozen_string_literal: true

class CourseWizard
  class Draft
    attr_reader :wizard, :state_store

    delegate :level,
             :is_send,
             :qualification,
             :campaign_name,
             :start_date,
             :primary_master_subject_id,
             :secondary_master_subject_id,
             :subordinate_subject_id,
             :can_sponsor_student_visa,
             :visa_sponsorship_application_deadline_required,
             :accredited_provider_code,
             to: :state_store

    def initialize(wizard:)
      @wizard = wizard
      @state_store = wizard.state_store
    end

    def tda?
      state_store.undergraduate_degree_with_qts?
    end

    def funding
      return "apprenticeship" if tda? && state_store.funding_type.blank?

      state_store.funding_type
    end

    def employment_based?
      funding.in?(%w[salary apprenticeship])
    end

    def study_modes
      patterns = Array(state_store.study_pattern).compact_blank
      return patterns if patterns.present?
      return %w[full_time] if tda?

      []
    end

    def can_sponsor_skilled_worker_visa
      return false if tda? && state_store.can_sponsor_skilled_worker_visa.nil?

      state_store.can_sponsor_skilled_worker_visa
    end

    def study_patterns_for_display
      patterns = Array(state_store.study_pattern).compact_blank
      return %w[full_time] if patterns.empty? && tda?

      patterns
    end

    def age_range_choice
      state_store.age_range_in_years
    end

    def age_range_in_years
      return age_range_choice unless age_range_choice == "other"
      return age_range_choice if course_age_range_in_years_other_from.blank? || course_age_range_in_years_other_to.blank?

      "#{course_age_range_in_years_other_from}_to_#{course_age_range_in_years_other_to}"
    end

    delegate :course_age_range_in_years_other_from, to: :state_store

    delegate :course_age_range_in_years_other_to, to: :state_store

    def master_subject_id
      return if state_store.further_education_level?

      state_store.primary_level? ? state_store.primary_master_subject_id : state_store.secondary_master_subject_id
    end

    def subject_ids
      return [] if state_store.further_education_level?
      return [state_store.primary_master_subject_id].compact_blank if state_store.primary_level?

      secondary_subject_ids_with_grouped_specialisms
    end

    def subjects
      @subjects ||= ordered_subject_records(subject_ids)
    end

    def school_ids
      Array(state_store.site_ids).compact_blank
    end

    def schools
      @schools ||= ordered_site_records(school_ids)
    end

    def study_site_ids
      return nil if state_store.study_sites_ids.nil?

      Array(state_store.study_sites_ids).compact_blank
    end

    def selected_study_site_ids
      Array(state_store.study_sites_ids).compact_blank
    end

    def study_sites
      @study_sites ||= ordered_site_records(selected_study_site_ids)
    end

    delegate :accrediting_provider, to: :wizard

    def accreditation_provider_name
      return if accredited_provider_code.blank?

      wizard.recruitment_cycle.providers.find_by(provider_code: accredited_provider_code)&.provider_name
    end

    def visa_deadline
      @visa_deadline ||= VisaDeadline.wrap(state_store.visa_sponsorship_application_deadline_at)
    end

  private

    def secondary_subject_ids_with_grouped_specialisms
      secondary_parent_ids.each_with_object([]) { |parent_id, ordered_ids|
        ordered_ids << parent_id
        ordered_ids.concat(specialism_ids_for_parent(parent_id))
      }.uniq
    end

    def secondary_parent_ids
      [
        state_store.secondary_master_subject_id,
        state_store.subordinate_subject_id,
      ].compact_blank
    end

    def specialism_ids_for_parent(parent_id)
      ids = []

      if state_store.modern_languages_specialisms? && parent_id.to_s == modern_languages_subject_id
        ids.concat(Array(state_store.language_ids))
      end

      if state_store.design_technology_specialisms? && parent_id.to_s == design_technology_subject_id
        ids.concat(Array(state_store.design_technology_ids))
      end

      ids.compact_blank
    end

    def modern_languages_subject_id
      @modern_languages_subject_id ||= SecondarySubject.modern_languages&.id&.to_s
    end

    def design_technology_subject_id
      @design_technology_subject_id ||= SecondarySubject.design_technology&.id&.to_s
    end

    def ordered_subject_records(ids)
      return [] if ids.blank?

      records_by_id = Subject.where(id: ids).index_by { |subject| subject.id.to_s }
      ids.filter_map { |id| records_by_id[id.to_s] }
    end

    def ordered_site_records(ids)
      return [] if ids.blank?

      records_by_id = Site.where(id: ids).index_by { |site| site.id.to_s }
      ids.filter_map { |id| records_by_id[id.to_s] }
    end
  end
end
