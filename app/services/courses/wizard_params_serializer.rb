# frozen_string_literal: true

module Courses
  class WizardParamsSerializer
    include ServicePattern

    attr_reader :answers

    def initialize(wizard:)
      @answers = wizard.state_store
    end

    def call
      ActionController::Parameters.new(mapped_params).permit!
    end

  private

    def mapped_params
      {
        "level" => answers.level,
        "is_send" => answers.is_send,
        "master_subject_id" => answers.master_subject_id,
        "subordinate_subject_id" => answers.subordinate_subject_id,
        "subjects_ids" => answers.subject_ids,
        "age_range_in_years" => answers.age_range,
        "qualification" => answers.qualification,
        "funding" => answers.funding,
        "study_mode" => answers.study_modes,
        "school_uuids" => answers.selected_school_uuids,
        "study_sites_ids" => answers.study_site_ids,
        "accredited_provider_code" => answers.accredited_provider_code,
        "start_date" => answers.start_date,
        "campaign_name" => answers.campaign_name,
        "can_sponsor_student_visa" => answers.can_sponsor_student_visa,
        "can_sponsor_skilled_worker_visa" => answers.can_sponsor_skilled_worker_visa_or_default,
        "visa_sponsorship_application_deadline_required" => answers.visa_sponsorship_application_deadline_required,
      }.compact.merge(mapped_visa_deadline_params)
    end

    def mapped_visa_deadline_params
      deadline = answers.visa_deadline
      return {} if deadline.blank?
      return {} if [deadline.year, deadline.month, deadline.day].any?(&:blank?)

      {
        "visa_sponsorship_application_deadline_at(1i)" => deadline.year.to_s,
        "visa_sponsorship_application_deadline_at(2i)" => deadline.month.to_s,
        "visa_sponsorship_application_deadline_at(3i)" => deadline.day.to_s,
      }
    end
  end
end
