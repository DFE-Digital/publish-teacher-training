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

    def text_search(model_data_scope, text_search)
      return model_data_scope if text_search.blank?

      model_data_scope.search(text_search)
    end

    def filter_model_data_scope
      text_search(model_data_scope, filters[:text_search])
    end
  end
end
