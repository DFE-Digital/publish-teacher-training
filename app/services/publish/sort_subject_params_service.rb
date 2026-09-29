# frozen_string_literal: true

module Publish
  # In each relevant controller, sort the subject ids in a predetermined order
  #
  # If there's one subject: [English]
  # If there's two subjects: [English, Mathematics]
  # If the master subject is Modern languages: [Modern Languages, *language_ids]
  # If the master is Modern languages and subordinate is D&T: [Modern Languages, *language_ids, D&T, *specialisms]
  # If the master is D&T and subordinate is Modern languages: [D&T, *specialisms, Modern Languages, *language_ids]
  #
  # This keeps the subject params predictable and consistent
  class SortSubjectParamsService
    include ServicePattern

    # Merges subject IDs from various form inputs into a single ordered array.
    def initialize(course:, subjects_ids:, language_ids: nil, design_technology_ids: nil)
      @course = course
      @subjects_ids = Array(subjects_ids).map(&:to_s)
      @language_ids = language_ids&.map(&:to_s)
      @design_technology_ids = design_technology_ids&.map(&:to_s)
    end

    def call
      parent_ids.flat_map do |id|
        specialisms = if id == ml_parent_id
                        resolved_language_ids
                      elsif id == dt_parent_id
                        resolved_dt_ids
                      else
                        []
                      end

        [id, *specialisms]
      end
    end

  private

    def parent_ids
      @subjects_ids.select { |id| available_parent_ids.include?(id) }
    end

    def resolved_language_ids
      source = @language_ids || @subjects_ids
      source.select { |id| available_language_ids.include?(id) }
    end

    def resolved_dt_ids
      source = @design_technology_ids || @subjects_ids
      source.select { |id| available_dt_ids.include?(id) }
    end

    def options
      @options ||= @course.edit_course_options
    end

    def ml_parent_id
      @ml_parent_id ||= options[:modern_languages_subject]&.id&.to_s
    end

    def dt_parent_id
      @dt_parent_id ||= options[:design_technology_subjects]&.id&.to_s
    end

    def available_parent_ids
      @available_parent_ids ||= stringify_ids(options[:subjects])
    end

    def available_language_ids
      @available_language_ids ||= stringify_ids(options[:modern_languages])
    end

    def available_dt_ids
      @available_dt_ids ||= stringify_ids(options[:design_technologies])
    end

    def stringify_ids(collection)
      collection.map { |s| s.id.to_s }
    end
  end
end
