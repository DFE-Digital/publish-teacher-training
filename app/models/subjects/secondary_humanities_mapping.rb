module Subjects
  class SecondaryHumanitiesMapping
    def initialize(course_title)
      @course_title = course_title
    end

    def applicable_to?(ucas_subjects)
      "humanities".in?(ucas_subjects) && @course_title =~ /humanities/
    end

    def to_dfe_subject
      "Humanities"
    end
  end
end
