module Publish
  module CourseSchoolsHelper
    def school_label_for(course)
      t("publish.courses.schools.heading.#{course.salaried? ? 'salaried' : 'unsalaried'}")
    end

    def school_warning_text(course)
      school_type = t("publish.courses.schools.#{course.salaried? ? 'salaried' : 'unsalaried'}").downcase
      t("publish.courses.schools.new.warning_text", school_type: school_type)
    end

    def school_label_with_plural(course, count:)
      prefix = t("publish.courses.schools.#{course.salaried? ? 'salaried' : 'unsalaried'}")
      t("publish.courses.schools.label", count: count, prefix: prefix)
    end
  end
end
