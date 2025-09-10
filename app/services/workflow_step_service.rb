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
      remove_applications_open(further_education_workflow_steps)
    elsif course.is_school_direct?
      remove_applications_open(
        school_direct_workflow_steps_with_accredited_provider_check - visas_to_remove(course) - sponsorship_application_steps_to_remove,
      )
    elsif course.is_uni_or_scitt?
      remove_applications_open(
        uni_or_scitt_workflow_steps - visas_to_remove(course) - sponsorship_application_steps_to_remove,
      )
    end
  end

private

  attr_reader :course

  def teacher_degree_apprenticeship_school_direct_workflow_steps
    %i[
      courses_list
      level
      subjects
    ] + special_steps + %i[
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
    ] + special_steps + %i[
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
    steps =
      if course.is_school_direct?
        teacher_degree_apprenticeship_school_direct_workflow_steps
      elsif course.is_uni_or_scitt?
        teacher_degree_apprenticeship_scitt_workflow_steps
      else
        []
      end

    remove_applications_open(steps.reject { |step| workflow_removed_steps.include?(step) })
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
    ] + special_steps + %i[
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
    ] + special_steps + %i[
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

  def workflow_removed_steps
    steps = []
    steps << :accredited_provider if course.provider.accredited_partners.length == 1
    steps
  end

  def special_steps
    physics_id = SecondarySubject.physics.id
    ml_id = SecondarySubject.modern_languages.id
    dt_id = SecondarySubject.design_technology.id

    case course.master_subject_id
    when dt_id
      %i[design_technology modern_languages engineers_teach_physics]
    when ml_id
      %i[modern_languages design_technology engineers_teach_physics]
    when physics_id
      %i[engineers_teach_physics modern_languages design_technology]
    else
      %i[engineers_teach_physics modern_languages design_technology]
    end
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
    school_direct_workflow_steps.reject { |step| workflow_removed_steps.include?(step) }
  end

  def remove_applications_open(steps)
    return steps unless FeatureFlag.active?(:hide_applications_open_date)

    steps - [:applications_open]
  end
end
