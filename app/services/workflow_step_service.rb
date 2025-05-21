# frozen_string_literal: true

class WorkflowStepService
  include ServicePattern

  def initialize(course, params)
    @course = course
    @params = params
  end

  def call
    return teacher_degree_apprenticeship_workflow_steps if course.undergraduate_degree_with_qts?

    if course.is_further_education?
      further_education_workflow_steps
    elsif course.is_school_direct?
      school_direct_workflow_steps_with_accredited_provider_check - visas_to_remove(course) - sponsorship_application_steps_to_remove
    elsif course.is_uni_or_scitt?
      uni_or_scitt_workflow_steps - visas_to_remove(course) - sponsorship_application_steps_to_remove
    end
  end

private

  attr_reader :course

  def teacher_degree_apprenticeship_school_direct_workflow_steps
    %i[
      courses_list
      level
      subjects
      engineers_teach_physics
      modern_languages
      age_range
      outcome
      school
      study_site
      accredited_provider
      applications_open
      start_date
      confirmation
    ]
  end

  def teacher_degree_apprenticeship_scitt_workflow_steps
    %i[
      courses_list
      level
      subjects
      engineers_teach_physics
      modern_languages
      age_range
      outcome
      school
      study_site
      applications_open
      start_date
      confirmation
    ]
  end

  def teacher_degree_apprenticeship_workflow_steps
    if course.is_school_direct?
      teacher_degree_apprenticeship_school_direct_workflow_steps - workflow_removed_steps
    elsif course.is_uni_or_scitt?
      teacher_degree_apprenticeship_scitt_workflow_steps - workflow_removed_steps
    end
  end

  def workflow_removed_steps
    return [] unless course.provider.accredited_partners.length == 1

    %i[accredited_provider]
  end

  def further_education_workflow_steps
    %i[
      courses_list
      level
      outcome
      funding_type
      full_or_part_time
      school
      study_site
      applications_open
      start_date
      confirmation
    ]
  end

  def school_direct_workflow_steps
    %i[
      courses_list
      level
      subjects
      engineers_teach_physics
      modern_languages
      age_range
      outcome
      funding_type
      full_or_part_time
      school
      study_site
      accredited_provider
      can_sponsor_student_visa
      can_sponsor_skilled_worker_visa
      visa_sponsorship_application_deadline_required
      visa_sponsorship_application_deadline_at
      applications_open
      start_date
      confirmation
    ]
  end

  def uni_or_scitt_workflow_steps
    %i[
      courses_list
      level
      subjects
      engineers_teach_physics
      modern_languages
      age_range
      outcome
      funding_type
      full_or_part_time
      school
      study_site
      can_sponsor_student_visa
      can_sponsor_skilled_worker_visa
      visa_sponsorship_application_deadline_required
      visa_sponsorship_application_deadline_at
      applications_open
      start_date
      confirmation
    ]
  end

  def visas_to_remove(course)
    if course.fee_based?
      [:can_sponsor_skilled_worker_visa]
    else
      [:can_sponsor_student_visa]
    end
  end

  def sponsorship_application_steps_to_remove
    if course.no_visa_sponsorship?
      %i[visa_sponsorship_application_deadline_required visa_sponsorship_application_deadline_at]
    elsif visa_sponsorship_application_deadline_required_param == false
      [:visa_sponsorship_application_deadline_at]
    else
      []
    end
  end

  def visa_sponsorship_application_deadline_required_param
    ActiveModel::Type::Boolean.new.cast(
      @params[:visa_sponsorship_application_deadline_required],
    )
  end

  def school_direct_workflow_steps_with_accredited_provider_check
    if course.provider.accredited_partners.length == 1
      school_direct_workflow_steps - [:accredited_provider]
    else
      school_direct_workflow_steps
    end
  end
end
