# frozen_string_literal: true

module Publish
  class CourseStudyModeForm < BaseModelForm
    alias course model

    FIELDS = %i[study_mode].freeze

    attr_accessor(*FIELDS)

    validates :study_mode,
              presence: true,
              inclusion: { in: Course.study_modes.keys }

    def study_mode_checked?(value)
      mode = study_mode.nil? ? model.study_mode : study_mode

      mode == value || mode == 'full_time_or_part_time'
    end

    private

    def valid_before_save
      course.ensure_site_statuses_match_study_mode if course.changed?
    end

    def compute_fields
      { study_mode: new_attributes[:study_mode]&.compact_blank&.sort&.join('_or_') }
    end
  end
end
