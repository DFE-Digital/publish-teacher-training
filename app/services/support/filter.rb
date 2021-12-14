# frozen_string_literal: true

module Support
  class Filter
    include ServicePattern

    def initialize(model_data_scope:, filter_model:)
      @model_data_scope = model_data_scope
      @filter_model = filter_model
      @pg_search_method = filter_model.pg_search_method
    end

    def call
      return model_data_scope unless filter_model.filters

      filter_model_data_scope
    end

  private

    attr_reader :model_data_scope, :filter_model

    def search(model_data_scope, filters)
      return model_data_scope if filters.values.all?(&:blank?)

      search_params = { provider_name_or_code: filters[:provider_search], course_code: filters[:course_search] }

      model_data_scope.search(**search_params)
    end

    def text_search(model_data_scope, text_search)
      return model_data_scope if text_search.blank?

      model_data_scope.public_send(pg_search_method(text_search))
    end

    def filter_model_data_scope
      if filter_model.filters.include?(:provider_search)
        search(model_data_scope, filter_model.filters)
      else
        text_search(model_data_scope, filter_model.filters[:text_search])
      end
    end
  end
end
