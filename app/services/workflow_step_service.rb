# frozen_string_literal: true

class WorkflowStepService
  include ServicePattern

  def initialize(course)
    @course = course
  end

  def call
    if course.is_further_education?
      further_education_workflow_steps - remove_study_site_if_feature_flag_disabled
    elsif course.is_uni_or_scitt?
      uni_or_scitt_workflow_steps - visas_to_remove(course) - remove_study_site_if_feature_flag_disabled
    elsif course.is_school_direct?
      if course.provider.accredited_bodies.length == 1
        school_direct_workflow_steps - (visas_to_remove(course) + [:accredited_provider]) - remove_study_site_if_feature_flag_disabled
      else
        school_direct_workflow_steps - visas_to_remove(course) - remove_study_site_if_feature_flag_disabled
      end
    end
  end

  private

  attr_reader :course

  def further_education_workflow_steps
    %i[
      courses_list
      level
      outcome
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
      apprenticeship
      full_or_part_time
      school
      study_site
      can_sponsor_student_visa
      can_sponsor_skilled_worker_visa
      applications_open
      start_date
      confirmation
    ]
  end

  def visas_to_remove(course)
    if course.funding_type.present?
      if course.is_fee_based?
        [:can_sponsor_skilled_worker_visa]
      elsif course.school_direct_salaried_training_programme? || course.pg_teaching_apprenticeship?
        [:can_sponsor_student_visa]
      end
    else
      %i[can_sponsor_student_visa can_sponsor_skilled_worker_visa]
    end
  end

  def remove_study_site_if_feature_flag_disabled
    FeatureService.enabled?(:study_sites) ? [] : [:study_site]
  end
end
