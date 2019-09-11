module UCASSubjects
  class CourseLevel
    SUBJECT_LEVEL = {
      ucas_further_education: ["further education",
                               "higher education",
                               "post-compulsory"],
      ucas_primary: ["early years",
                     "upper primary",
                     "primary",
                     "lower primary"],
      ucas_unexpected: ["construction and the built environment",
                        # "history of art",
                        "home economics",
                        "hospitality and catering",
                        "personal and social education",
                        # "philosophy",
                        "sport and leisure",
                        "environmental science",
                        "law"]
    }.freeze

    def initialize(ucas_subjects)
      @ucas_subjects = ucas_subjects
    end

    def ucas_level
      ucas_subjects = @ucas_subjects.map(&:strip).map(&:downcase)
      if (ucas_subjects & SUBJECT_LEVEL[:ucas_unexpected]).any?
        raise "found unsupported subject name(s): #{(ucas_subjects & SUBJECT_LEVEL[:ucas_unexpected]) * ', '}"
      elsif (ucas_subjects & SUBJECT_LEVEL[:ucas_primary]).any?
        :primary
      elsif (ucas_subjects & SUBJECT_LEVEL[:ucas_further_education]).any?
        :further_education
      else
        :secondary
      end
    end
  end
end
