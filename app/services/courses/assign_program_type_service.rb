# frozen_string_literal: true

module Courses
  class AssignProgramTypeService
    def execute(funding_type, course)
      provider_type = course.provider.provider_type
      program_type = determine_program_type(funding_type, provider_type, course)

      course.program_type = program_type
    end

    private

    def determine_program_type(funding_type, provider_type, course)
      case funding_type
      when 'salary'
        calculate_salary_program(provider_type)
      when 'apprenticeship'
        if course.teacher_degree_apprenticeship?
          course.program_type
        else
          :pg_teaching_apprenticeship
        end
      when 'fee'
        calculate_fee_program(provider_type)
      else
        course.program_type # Default to current program_type if funding_type is not recognised
      end
    end

    def calculate_salary_program(provider_type)
      case provider_type
      when 'scitt'
        :scitt_salaried_programme
      when 'university'
        :higher_education_salaried_programme
      else
        :school_direct_salaried_training_programme
      end
    end

    def calculate_fee_program(provider_type)
      if provider_type == 'scitt'
        :scitt_programme
      elsif provider_type == 'university'
        :higher_education_programme
      else
        :school_direct_training_programme
      end
    end
  end
end
