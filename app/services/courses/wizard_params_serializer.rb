# frozen_string_literal: true

module Courses
  class WizardParamsSerializer
    include ServicePattern

    attr_reader :draft

    def initialize(wizard:)
      @draft = CourseWizard::Draft.new(wizard:)
    end

    def call
      ActionController::Parameters.new(mapped_params).permit!
    end

  private

    def mapped_params
      {
        "level" => draft.level,
        "is_send" => draft.is_send,
        "master_subject_id" => draft.master_subject_id,
        "subordinate_subject_id" => draft.subordinate_subject_id,
        "subjects_ids" => draft.subject_ids,
        "age_range_in_years" => draft.age_range_in_years,
        "qualification" => draft.qualification,
        "funding" => draft.funding,
        "study_mode" => draft.study_modes,
        "sites_ids" => draft.school_ids,
        "study_sites_ids" => draft.study_site_ids,
        "accredited_provider_code" => draft.accredited_provider_code,
        "start_date" => draft.start_date,
        "campaign_name" => draft.campaign_name,
        "can_sponsor_student_visa" => draft.can_sponsor_student_visa,
        "can_sponsor_skilled_worker_visa" => draft.can_sponsor_skilled_worker_visa,
        "visa_sponsorship_application_deadline_required" => draft.visa_sponsorship_application_deadline_required,
      }.compact.merge(mapped_visa_deadline_params)
    end

    def mapped_visa_deadline_params
      return {} if draft.visa_deadline.blank?
      return {} if [draft.visa_deadline.year, draft.visa_deadline.month, draft.visa_deadline.day].any?(&:blank?)

      {
        "visa_sponsorship_application_deadline_at(1i)" => draft.visa_deadline.year.to_s,
        "visa_sponsorship_application_deadline_at(2i)" => draft.visa_deadline.month.to_s,
        "visa_sponsorship_application_deadline_at(3i)" => draft.visa_deadline.day.to_s,
      }
    end
  end
end
