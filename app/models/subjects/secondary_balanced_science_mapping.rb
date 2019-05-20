module Subjects
  class SecondaryBalancedScienceMapping
    def initialize(course_title)
      @course_title = course_title
    end

    def applicable_to?(ucas_subjects)
      "science".in?(ucas_subjects) && @course_title =~ /(?<!social |computer )science/
    end

    def to_dfe_subject
      "Balanced science"
    end
  end
end
