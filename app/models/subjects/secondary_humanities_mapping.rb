module Subjects
  class SecondaryHumanitiesMapping
    def applicable_to?(ucas_subjects, course_title)
      "humanities".in?(ucas_subjects) && course_title =~ /humanities/
    end

    def to_dfe_subject
      "Humanities"
    end
  end
end
