# frozen_string_literal: true

class Program
  def self.from_type(program_type)
    {
      higher_education_programme: HigherEducationProgramme,
      higher_education_salaried_programme: HigherEducationSalariedProgramme,
      school_direct_training_programme: SchoolDirectTrainingProgramme,
      school_direct_salaried_training_programme: SchoolDirectSalariedTrainingProgramme,
      scitt_programme: SCITTProgramme,
      scitt_salaried_programme: SCITTSalariedProgramme,
      pg_teaching_apprenticeship: PostgraduateTeachingApprenticeship,
      teacher_degree_apprenticeship: TeacherDegreeApprenticeship,
    }.fetch(program_type.to_sym, nil)
  end

  def self.funding_type(funding_type)
    ActiveSupport::StringInquirer.new(funding_type)
  end
end

class HigherEducationProgramme < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('fee')
  end
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
end

class SchoolDirectSalariedTrainingProgramme < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('salary')
  end
end

class SCITTProgramme < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('fee')
  end
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
end

class TeacherDegreeApprenticeship < Program
  def self.funding_type
    ActiveSupport::StringInquirer.new('apprenticeship')
  end
end
