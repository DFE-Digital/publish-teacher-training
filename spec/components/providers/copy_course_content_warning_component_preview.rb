# frozen_string_literal: true

module Providers
  class CopyCourseContentWarningComponentPreview < ViewComponent::Preview
    def with_many_fields
      source_course = Course.new(name: 'Course name', course_code: 'AFGT')
      copied_fields = [
        ['About this course', 'about_this_course'],
        ['How placements work', 'how_placements_work']
      ]
      render(
        CopyCourseContentWarningComponent.new(
          copied_fields,
          'form-identifier',
          source_course
        )
      )
    end

    def with_one_field
      source_course = Course.new(name: 'Course name', course_code: 'AFGT')
      copied_fields = [['How placements work', 'how_placements_work']]
      render(
        CopyCourseContentWarningComponent.new(
          copied_fields,
          'form-identifier',
          source_course
        )
      )
    end
  end
end
