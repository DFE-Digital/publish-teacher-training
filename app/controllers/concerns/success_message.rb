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

  def schools_added_message(schools, unsaved_schools = [])
    return if schools.empty? && unsaved_schools.empty?
    return flash[:success] = schools_added_text(schools) if unsaved_schools.empty?

    flash[:warning] = {
      "title" => I18n.t("warning.schools_not_added_title", items_not_added: school_count(unsaved_schools)),
      "body" => schools_not_added_body(schools, unsaved_schools),
    }
  end

private

  def schools_added_text(schools)
    I18n.t("success.added", items_added: school_count(schools))
  end

  def schools_not_added_body(schools, unsaved_schools)
    not_added = I18n.t("warning.schools_not_added_body", urns: unsaved_schools.map(&:urn).to_sentence)

    [(schools_added_text(schools) if schools.any?), not_added].compact.join(". ")
  end

  def school_count(schools)
    "#{schools.size} #{'school'.pluralize(schools.size)}"
  end

  def published_course_for_live_message?
    current_course = if respond_to?(:course, true)
                       course
                     elsif instance_variable_defined?(:@course)
                       @course
                     end

    current_course.respond_to?(:is_published?) && current_course.is_published?
  end
end
