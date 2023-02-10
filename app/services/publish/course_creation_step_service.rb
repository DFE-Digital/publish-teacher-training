# frozen_string_literal: true

module Publish
  class CourseCreationStepService
    def execute(current_step:, course:)
      workflow_steps = get_workflow_steps(course)
      {
        next: get_next_step(workflow_steps, current_step),
        previous: get_previous_step(workflow_steps, current_step)
      }
    end

    def get_next_step(steps, current_step)
      next_step_index = steps.find_index(current_step).next
      steps[next_step_index]
    end

    def get_previous_step(steps, current_step)
      previous_step_index = steps.find_index(current_step).pred
      steps[previous_step_index]
    end

    private

    def get_workflow_steps(course)
      if course.is_further_education?
        further_education_workflow_steps
      elsif course.is_uni_or_scitt?
        uni_or_scitt_workflow_steps - visas_to_remove(course)
      elsif course.is_school_direct?
        school_direct_workflow_steps - visas_to_remove(course)
      end
    end

    def further_education_workflow_steps
      %i[
        courses_list
        level
        outcome
        full_or_part_time
        location
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
        location
        accredited_body
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
        location
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
  end
end
