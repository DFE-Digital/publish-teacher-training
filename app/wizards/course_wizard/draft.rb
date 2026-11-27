# frozen_string_literal: true

class CourseWizard
  # The records a course's answers name, for check answers: its subjects,
  # schools, study sites and accrediting provider. The answers themselves, and
  # their defaults, are read from the state store.
  class Draft
    attr_reader :wizard, :state_store

    delegate_missing_to :state_store
    delegate :accrediting_provider, to: :wizard

    def initialize(wizard:)
      @wizard = wizard
      @state_store = wizard.state_store
    end

    def subjects
      @subjects ||= ordered_subject_records(subject_ids)
    end

    def schools
      @schools ||= ordered_school_records(selected_school_uuids)
    end

    def study_sites
      @study_sites ||= ordered_study_site_records(Array(study_site_ids))
    end

    def accreditation_provider_name
      return if accredited_provider_code.blank?

      wizard.recruitment_cycle.providers.find_by(provider_code: accredited_provider_code)&.provider_name
    end

  private

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
