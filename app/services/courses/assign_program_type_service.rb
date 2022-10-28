module Courses
  class AssignProgramTypeService
    def execute(funding_type, course)
      case funding_type
      when "salary"
        course.program_type = :school_direct_salaried_training_programme
      when "apprenticeship"
        course.program_type = :pg_teaching_apprenticeship
      when "fee"
        course.program_type = calculate_fee_program(course)
      end

      # NOTE: This looks like unwarranted side effects
      course.save
    end

  private

    def calculate_fee_program(course)
      if !course.self_accredited?
        :school_direct_training_programme
      elsif course.provider.scitt?
        :scitt_programme
      else
        :higher_education_programme
      end
    end
  end
end
