# frozen_string_literal: true

module Publish
  class MergeSubjectIdsService
    include ServicePattern

    # Merges subject IDs from various form inputs into a single ordered array.
    #
    # @param course [Course] used to look up available subjects via edit_course_options
    # @param subjects_ids [Array] parent subject IDs (master/subordinate) — order is preserved for master/subordinate assignment
    # @param language_ids [Array, nil] explicit language selections from checkboxes; when nil, languages are preserved from all_subjects_ids
    # @param design_technology_ids [Array, nil] explicit D&T specialism selections from checkboxes; when nil, preserved from all_subjects_ids
    # @param all_subjects_ids [Array, nil] the full previous subjects_ids (used to extract preserved specialisms); defaults to subjects_ids
    def initialize(course:, subjects_ids:, language_ids: nil, design_technology_ids: nil, all_subjects_ids: nil)
      @course = course
      @subjects_ids = Array(subjects_ids).map(&:to_s)
      @all_subjects_ids = (all_subjects_ids ? Array(all_subjects_ids).map(&:to_s) : @subjects_ids)
      @language_ids = language_ids&.map(&:to_s)
      @design_technology_ids = design_technology_ids&.map(&:to_s)
    end

    def call
      result = []

      parent_ids.each do |id|
        result << id

        if id == ml_parent_id
          result.concat(resolved_language_ids)
        elsif id == dt_parent_id
          result.concat(resolved_dt_ids)
        end
      end

      result
    end

  private

    def parent_ids
      @subjects_ids.select { |id| available_parent_ids.include?(id) }
    end

    def resolved_language_ids
      source = @language_ids || @all_subjects_ids
      source.select { |id| available_language_ids.include?(id) }
    end

    def resolved_dt_ids
      source = @design_technology_ids || @all_subjects_ids
      source.select { |id| available_dt_ids.include?(id) }
    end

    def ml_parent_id
      @ml_parent_id ||= @course.edit_course_options[:modern_languages_subject]&.id&.to_s
    end

    def dt_parent_id
      @dt_parent_id ||= @course.edit_course_options[:design_technology_subjects]&.id&.to_s
    end

    def available_parent_ids
      @available_parent_ids ||= @course.edit_course_options[:subjects].map(&:id).map(&:to_s)
    end

    def available_language_ids
      @available_language_ids ||= @course.edit_course_options[:modern_languages].map(&:id).map(&:to_s)
    end

    def available_dt_ids
      @available_dt_ids ||= @course.edit_course_options[:design_technologies].map(&:id).map(&:to_s)
    end
  end
end
