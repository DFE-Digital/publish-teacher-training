module Publish
  module CourseInterviewLocationHelper
    def display_interview_location(raw_value)
      return nil if raw_value.blank?

      key = raw_value.to_s.underscore
      I18n.t("publish.providers.courses.description_content.interview_location.#{key}", default: raw_value.to_s.humanize)
    end
  end
end
