# frozen_string_literal: true

module Support
  class Filter
    include ServicePattern

    def initialize(model_data_scope:, filters:)
      @model_data_scope = model_data_scope
      @filters = filters
    end

    def call
      return model_data_scope unless filters

      filter_model_data_scope
    end

  private

    attr_reader :model_data_scope, :filters

    def provider_and_course_search(model_data_scope, provider_search, course_search)
      return model_data_scope if provider_search.blank? && course_search.blank?

      if course_search.blank?
        model_data_scope.search(provider_search)
      elsif provider_search.blank?
        model_data_scope.joins(:courses).where("lower(course.course_code) = ?", course_search.downcase)
      else
        model_data_scope.search(provider_search).joins(:courses).where("lower(course.course_code) = ?", course_search.downcase)
      end
    end

    def text_search(model_data_scope, text_search)
      return model_data_scope if text_search.blank?

      model_data_scope.search(text_search)
    end

    def filter_model_data_scope
      if filters.include?(:provider_search)
        provider_and_course_search(model_data_scope, filters[:provider_search], filters[:course_search])
      else
        text_search(model_data_scope, filters[:text_search])
      end
    end
  end
end
