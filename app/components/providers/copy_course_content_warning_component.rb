# frozen_string_literal: true

module Providers
  class CopyCourseContentWarningComponent < ApplicationComponent
    include I18n
    def initialize(copied_fields, form_identifier, source_course, **)
      super(**)
      @copied_fields = copied_fields
      @form_identifier = form_identifier
      @source_course = source_course
    end

    def field_links
      @copied_fields.map do |name, field|
        [name, "##{@form_identifier}-#{field.gsub('_', '-')}-field"]
      end
    end

    def please_check_changes
      translation_base = 'components.providers.copy_course_content_warning_component.please_check_changes'
      t("#{translation_base}.#{plural? ? 'plural' : 'singular'}")
    end

    def copied_fields_from
      translation_base = 'components.providers.copy_course_content_warning_component.copied_fields_from'
      t("#{translation_base}.#{plural? ? 'plural' : 'singular'}",
        name_and_code: "#{@source_course.name} (#{@source_course.course_code})")
    end

    def plural?
      @copied_fields.length > 1
    end
  end
end
