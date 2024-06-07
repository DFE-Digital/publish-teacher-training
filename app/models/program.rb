# frozen_string_literal: true

class Program
  def self.all
    {
      higher_education_programme: HigherEducationProgramme,
      higher_education_salaried_programme: HigherEducationSalariedProgramme,
      school_direct_training_programme: SchoolDirectTrainingProgramme,
      school_direct_salaried_training_programme: SchoolDirectSalariedTrainingProgramme,
      scitt_programme: SCITTProgramme,
      scitt_salaried_programme: SCITTSalariedProgramme,
      pg_teaching_apprenticeship: PostgraduateTeachingApprenticeship,
      teacher_degree_apprenticeship: TeacherDegreeApprenticeship
    }
  end

  def self.from_type(program_type)
    return UnknownProgramme unless program_type

    all.fetch(program_type.to_sym, UnknownProgramme)
  end

  def self.funding_type
    NotImplementedError
  end

  def self.fee_based?
    funding_type.fee?
  end

  def self.sponsors_student_visa? = false
  def self.sponsors_skilled_worker_visa? = false

  def self.where_salaried
    where_funding_types(%w[salary apprenticeship])
  end

  def self.where_funding_types(funding_types = [])
    funding_types = Array(funding_types)
    all.select { |_key, value| funding_types.include?(value.funding_type) }.keys
  end

  def self.where_sponsor_student_visa
    all.select { |_key, value| value.sponsors_student_visa? }.keys
  end

  def self.where_sponsor_skilled_worker_visa
    all.select { |_key, value| value.sponsors_skilled_worker_visa? }.keys
  end
end

class UnknownProgramme < Program
  def self.funding_type
    nil
  end

  def self.fee_based?
    false
  end
end

class HigherEducationProgramme < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('fee')
  end

  def self.sponsors_student_visa? = true
end

class HigherEducationSalariedProgramme < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('salary')
  end
end

class SchoolDirectTrainingProgramme < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('fee')
  end

  def self.sponsors_student_visa? = true
end

class SchoolDirectSalariedTrainingProgramme < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('salary')
  end

  def self.sponsors_skilled_worker_visa? = true
end

class SCITTProgramme < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('fee')
  end

  def self.sponsors_student_visa? = true
end

class SCITTSalariedProgramme < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('salary')
  end
end

class PostgraduateTeachingApprenticeship < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('apprenticeship')
  end

  def self.sponsors_skilled_worker_visa? = true
end

class TeacherDegreeApprenticeship < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('apprenticeship')
  end
end
