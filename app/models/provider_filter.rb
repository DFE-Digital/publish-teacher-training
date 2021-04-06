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
    @merged_filters ||= text_search.with_indifferent_access
  end

  def text_search
    return {} if params[:text_search].blank?

    { "text_search" => params[:text_search] }
  end
end
