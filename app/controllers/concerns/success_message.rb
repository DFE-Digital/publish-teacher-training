# frozen_string_literal: true

module SuccessMessage
  extend ActiveSupport::Concern

  def course_updated_message(value)
    raise TypeError unless value.is_a?(String)

    title = I18n.t("success.saved", value:)

    if published_course_for_live_message?
      flash[:success_with_body] = {
        "title" => title,
        "body" => I18n.t("success.changes_now_live"),
      }
    else
      flash[:success] = title
    end
  end

  def schools_added_message(schools)
    items_added = schools.size > 1 ? "#{schools.size} schools" : "1 school"
    flash[:success] = I18n.t("success.added", items_added:)
  end

private

  def published_course_for_live_message?
    current_course = if respond_to?(:course, true)
                       course
                     elsif instance_variable_defined?(:@course)
                       @course
                     end

    current_course.respond_to?(:is_published?) && current_course.is_published?
  end
end
