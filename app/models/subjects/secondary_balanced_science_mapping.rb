module Subjects
  class SecondaryBalancedScienceMapping
    def applicable_to?(ucas_subjects, course_title)
      "science".in?(ucas_subjects) && course_title =~ /(?<!social |computer )science/
    end

    def to_dfe_subject
      "Balanced science"
    end
  end
end
