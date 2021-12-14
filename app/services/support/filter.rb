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
      return model_data_scope unless filter_model.filters&.values&.any?(&:present?)

      filter_model_data_scope
    end

  private

    attr_reader :model_data_scope, :filter_model, :pg_search_method

    def search_provider_or_course
      search_params = { provider_name_or_code: filter_model.filters[:provider_search], course_code: filter_model.filters[:course_search] }

      model_data_scope.search(**search_params)
    end

    def text_search(text_search)
      model_data_scope.public_send(pg_search_method, text_search)
    end

    def filter_model_data_scope
      return search_provider_or_course if filter_model.is_a? Support::Providers::Filter

      text_search(filter_model.filters[:text_search])
    end
  end
end
