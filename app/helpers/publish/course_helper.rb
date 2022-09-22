module Publish
  module CourseHelper
    def course_value_provided?(value)
      value.presence || tag.span(t("course.value_not_entered"), class: "govuk-hint").html_safe
    end
  end
end
