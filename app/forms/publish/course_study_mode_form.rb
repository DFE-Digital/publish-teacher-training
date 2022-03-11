module Publish
  class CourseStudyModeForm < BaseModelForm
    alias_method :course, :model

    FIELDS = %i[study_mode].freeze

    attr_accessor(*FIELDS)

    validates :study_mode,
              presence: true,
              inclusion: { in: Course.study_modes.keys }

  private

    def compute_fields
      course.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
