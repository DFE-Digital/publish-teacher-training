# frozen_string_literal: true

class Program
  class << self
    def all
      {
        higher_education_programme: HigherEducationProgramme,
        higher_education_salaried_programme: HigherEducationSalariedProgramme,
        school_direct_training_programme: SchoolDirectTrainingProgramme,
        school_direct_salaried_training_programme: SchoolDirectSalariedTrainingProgramme,
        scitt_programme: SCITTProgramme,
        scitt_salaried_programme: SCITTSalariedProgramme,
        pg_teaching_apprenticeship: PostgraduateTeachingApprenticeship,
        teacher_degree_apprenticeship: TeacherDegreeApprenticeship,
      }
    end

    def from_type(program_type)
      return UnknownProgramme unless program_type

      all.fetch(program_type.to_sym, UnknownProgramme)
    end

    # --- Funding type ---
    def funding_type = nil

    def fee_based?
      funding_type&.fee?
    end

    def where_salaried
      where_funding_types(%w[salary apprenticeship])
    end

    def where_funding_types(funding_types = [])
      funding_types = Array(funding_types)
      all.select { |_key, value| funding_types.include?(value.funding_type) }.keys
    end
    # --- End of Funding type ---

    # --- Visa sponsorship ---
    def sponsors_student_visa? = false

    def sponsors_skilled_worker_visa? = false

    def visa_type
      type = fee_based? ? "student" : "skilled_worker"
      ActiveSupport::StringInquirer.new(type)
    end

    def where_sponsor_student_visa
      all.select { |_key, value| value.sponsors_student_visa? }.keys
    end

    def where_sponsor_skilled_worker_visa
      all.select { |_key, value| value.sponsors_skilled_worker_visa? }.keys
    end

    def student_visa?
      visa_type.student?
    end
    # --- End of Visa sponsorship ---
  end
end
