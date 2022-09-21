module Publish
  module CourseHelper
    def course_value_provided?(value)
      value.presence || t("course.value_not_provided")
    end
  end
end
