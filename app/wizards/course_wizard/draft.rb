# frozen_string_literal: true

class CourseWizard
  class Draft
    attr_reader :wizard, :state_store

    ANSWERS = %i[
      level
      is_send
      qualification
      campaign_name
      start_date
      primary_master_subject_id
      secondary_master_subject_id
      subordinate_subject_id
      can_sponsor_student_visa
      visa_sponsorship_application_deadline_required
      accredited_provider_code
    ].freeze

    ANSWERS.each do |attribute|
      define_method(attribute) { answer(attribute) }
    end

    def initialize(wizard:)
      @wizard = wizard
      @state_store = wizard.state_store
    end

    # An answer whose step is on the path to check answers, or nil. An answer
    # left behind on another branch (for example a visa answer kept after the
    # level changed to further education) never reaches the course or the
    # review rows.
    def answer(attribute)
      state_store.public_send(attribute) if on_path_attributes.include?(attribute)
    end

    def tda?
      state_store.undergraduate_degree_with_qts?
    end

    def funding
      return "apprenticeship" if tda? && answer(:funding_type).blank?

      answer(:funding_type)
    end

    def employment_based?
      funding.in?(%w[salary apprenticeship])
    end

    def study_modes
      patterns = Array(answer(:study_pattern)).compact_blank
      return patterns if patterns.present?
      return %w[full_time] if tda?

      []
    end

    def can_sponsor_skilled_worker_visa
      return false if tda? && answer(:can_sponsor_skilled_worker_visa).nil?

      answer(:can_sponsor_skilled_worker_visa)
    end

    def study_patterns_for_display
      patterns = Array(answer(:study_pattern)).compact_blank
      return %w[full_time] if patterns.empty? && tda?

      patterns
    end

    def age_range_choice
      answer(:age_range_in_years)
    end

    def age_range_in_years
      return age_range_choice unless age_range_choice == "other"
      return age_range_choice if course_age_range_in_years_other_from.blank? || course_age_range_in_years_other_to.blank?

      "#{course_age_range_in_years_other_from}_to_#{course_age_range_in_years_other_to}"
    end

    def course_age_range_in_years_other_from
      answer(:course_age_range_in_years_other_from)
    end

    def course_age_range_in_years_other_to
      answer(:course_age_range_in_years_other_to)
    end

    def master_subject_id
      return if state_store.further_education_level?

      state_store.primary_level? ? primary_master_subject_id : secondary_master_subject_id
    end

    def subject_ids
      return [] if state_store.further_education_level?
      return [primary_master_subject_id].compact_blank if state_store.primary_level?

      secondary_subject_ids_with_grouped_specialisms
    end

    def subjects
      @subjects ||= ordered_subject_records(subject_ids)
    end

    def school_uuids
      Array(answer(:school_uuids)).compact_blank
    end

    def schools
      @schools ||= ordered_school_records(school_uuids)
    end

    def study_site_ids
      return nil if answer(:study_sites_ids).nil?

      Array(answer(:study_sites_ids)).compact_blank
    end

    def selected_study_site_ids
      Array(answer(:study_sites_ids)).compact_blank
    end

    def study_sites
      @study_sites ||= ordered_study_site_records(selected_study_site_ids)
    end

    def accrediting_provider
      @accrediting_provider ||= Accreditation.new(
        provider: wizard.provider,
        selected_provider_code: accredited_provider_code,
      ).accrediting_provider
    end

    def accreditation_provider_name
      return if accredited_provider_code.blank?

      wizard.recruitment_cycle.providers.find_by(provider_code: accredited_provider_code)&.provider_name
    end

    def visa_deadline
      @visa_deadline ||= VisaDeadline.wrap(answer(:visa_sponsorship_application_deadline_at))
    end

  private

    def on_path_attributes
      @on_path_attributes ||= wizard.data[:steps].values.flat_map(&:keys).to_set(&:to_sym)
    end

    def secondary_subject_ids_with_grouped_specialisms
      secondary_parent_ids.each_with_object([]) { |parent_id, ordered_ids|
        ordered_ids << parent_id
        ordered_ids.concat(specialism_ids_for_parent(parent_id))
      }.uniq
    end

    def secondary_parent_ids
      [
        secondary_master_subject_id,
        subordinate_subject_id,
      ].compact_blank
    end

    def specialism_ids_for_parent(parent_id)
      ids = []

      if state_store.modern_languages_specialisms? && parent_id.to_s == modern_languages_subject_id
        ids.concat(Array(answer(:language_ids)))
      end

      if state_store.design_technology_specialisms? && parent_id.to_s == design_technology_subject_id
        ids.concat(Array(answer(:design_technology_ids)))
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

    def ordered_study_site_records(ids)
      return [] if ids.blank?

      records_by_id = wizard.provider.study_sites.where(id: ids).index_by { |site| site.id.to_s }
      ids.filter_map { |id| records_by_id[id.to_s] }
    end

    # A school UUID that no longer resolves is logged and left out, rather than
    # blanking the whole review row.
    def ordered_school_records(uuids)
      ::Schools::UuidResolver.new(
        provider: wizard.provider,
        uuids:,
        log_tag: "CourseWizard::Draft",
      ).schools
    end
  end
end
