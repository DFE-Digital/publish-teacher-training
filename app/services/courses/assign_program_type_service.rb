# frozen_string_literal: true

module Courses
  class AssignProgramTypeService
    def execute(funding_type, course)
      program_type = {
        'salary' => calculate_salary_program(course),
        'apprenticeship' => :pg_teaching_apprenticeship,
        'fee' => calculate_fee_program(course),
      }.fetch(funding_type, course.program_type)

      course.program_type = program_type
    end

    private

    def calculate_salary_program(course)
      return :scitt_salaried_programme if course.provider.scitt?
      return :higher_education_salaried_programme if course.provider.university?

      :school_direct_salaried_training_programme
    end

    def calculate_fee_program(course)
      return :school_direct_training_programme unless course.self_accredited?
      return :scitt_programme if course.provider.scitt?

      :higher_education_programme
    end
  end
end
