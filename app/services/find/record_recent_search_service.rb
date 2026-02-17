# frozen_string_literal: true

module Find
  class RecordRecentSearchService
    def self.call(candidate:, search_params:)
      new(candidate, search_params).call
    end

    def initialize(candidate, search_params)
      @candidate = candidate
      @search_params = search_params.to_h.with_indifferent_access
    end

    def call
      return unless @candidate
      return unless meaningful_search?

      dedup_attrs = {
        subjects: extract_subjects,
        longitude: @search_params[:longitude]&.to_f,
        latitude: @search_params[:latitude]&.to_f,
        radius: @search_params[:radius]&.to_i,
      }

      existing = @candidate.recent_searches.kept.find_by(dedup_attrs)

      if existing
        existing.update!(search_attributes: filter_attributes, updated_at: Time.current)
        existing
      else
        @candidate.recent_searches.create!(
          **dedup_attrs,
          search_attributes: filter_attributes,
        )
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
      Sentry.capture_exception(e)
      nil
    end

  private

    def meaningful_search?
      extract_subjects.any? ||
        @search_params[:longitude].present? ||
        non_default_filters?
    end

    def non_default_filters?
      defaults = SearchParamDefaults.new(@search_params)
      filter_attributes.any? { |k, v| defaults.non_default?(k, v) }
    end

    def extract_subjects
      codes = Array(@search_params[:subjects]).compact_blank
      codes << @search_params[:subject_code] if @search_params[:subject_code].present?
      codes.uniq.sort
    end

    def filter_attributes
      @search_params
        .slice(*SearchAttributesValidator::PERMITTED_KEYS)
        .except(:subject_code)
        .compact_blank
    end
  end
end
