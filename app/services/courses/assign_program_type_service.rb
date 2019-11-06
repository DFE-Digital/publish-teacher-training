module Courses
  class AssignProgramTypeService
    def execute(funding_type, course)
      case funding_type
      when "salary"
        if !course.self_accredited?
          course.program_type = :school_direct_salaried_training_programme
        else
          course.errors.add(:program_type, "Salary is not valid for a self accredited course")
        end
      when "apprenticeship"
        course.program_type = :pg_teaching_apprenticeship
      when "fee"
        course.program_type = if !course.self_accredited?
                                :school_direct_training_programme
                              elsif course.provider.scitt?
                                :scitt_programme
                              else
                                :higher_education_programme
                              end
      end
    end
  end
end
