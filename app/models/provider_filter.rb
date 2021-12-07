# frozen_string_literal: true

class ProviderFilter
  def initialize(params:)
    @params = params
  end

  def filters
    return if params.empty? && merged_filters.empty?

    merged_filters
  end

private

  attr_reader :params

  def merged_filters
    @merged_filters ||= params.include?("text_search") ? text_search.with_indifferent_access : provider_and_course_search.with_indifferent_access
  end

  def text_search
    return {} if params[:text_search].blank?

    {
      "text_search" => params[:text_search],
    }
  end

  def provider_and_course_search
    return {} if params[:provider_search].blank? && params[:course_search].blank?

    {
      "provider_search" => params[:provider_search],
      "course_search" => params[:course_search],
    }
  end
end
