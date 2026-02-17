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

    def extract_subjects
      Array(@search_params[:subjects]).compact_blank.sort
    end

    def filter_attributes
      @search_params
        .slice(*SearchAttributesValidator::PERMITTED_KEYS)
        .compact_blank
    end
  end
end
