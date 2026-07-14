module Publish
  module CourseSchoolsHelper
    # Long school lists are collapsed to this many rows, with a "Show all schools"
    # link revealing the rest. Shared by the course schools edit page and the add
    # course wizard's schools step.
    SCHOOLS_COLLAPSE_THRESHOLD = 20

    def schools_collapse_threshold
      SCHOOLS_COLLAPSE_THRESHOLD
    end

    def school_label_for(course)
      t("publish.courses.schools.heading.#{course_type_key(course)}")
    end

    def school_warning_text(course)
      school_type = t("publish.courses.schools.#{course_type_key(course)}").downcase
      t("publish.courses.schools.new.warning_text", school_type: school_type)
    end

    def school_label_with_plural(course, count:)
      prefix = t("publish.courses.schools.#{course_type_key(course)}")
      t("publish.courses.schools.label", count: count, prefix: prefix)
    end

    def course_type_key(course)
      course.salaried? ? "salaried" : "unsalaried"
    end
  end
end
