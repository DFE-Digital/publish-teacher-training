# frozen_string_literal: true

module Support
  class Filter
    include ServicePattern

    def initialize(model_data_scope:, filter_params:)
      @model_data_scope = model_data_scope
      @filter_params = filter_params
    end

    def call
      filter_records.page(filter_params[:page] || 1)
    end

  private

    attr_reader :model_data_scope, :filter_params

    def text_search(records, text_search)
      return records if text_search.blank?

      records.search(text_search)
    end

    def course_search(records, search)
      return records if search.blank?

      records.course_search(search)
    end

    def provider_search(records, search)
      return records if search.blank?

      records.provider_search(search)
    end

    def user_type(records, user_type_arr)
      return records if user_type_arr&.all?(&:blank?)

      case user_type_arr
      when ['admin']
        records.admins
      when ['provider']
        records.non_admins
      else
        records
      end
    end

    def filter_records
      filtered_records = model_data_scope

      filtered_records = text_search(filtered_records, filter_params[:text_search]) if filtered_records.respond_to?(:search)
      filtered_records = provider_search(filtered_records, filter_params[:provider_search]) if filtered_records.respond_to?(:provider_search)
      filtered_records = course_search(filtered_records, filter_params[:course_search]) if filtered_records.respond_to?(:course_search)
      filtered_records = user_type(filtered_records, filter_params[:user_type]) if filtered_records.respond_to?(:admins)

      filtered_records
    end
  end
end
