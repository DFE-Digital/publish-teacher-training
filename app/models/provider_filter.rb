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
    @merged_filters ||= params.include?("text_search") ? text_search : provider_and_course_search
  end

  def text_search
    params.slice(:text_search)
  end

  def provider_and_course_search
    params.slice(:provider_search, :course_search)
  end
end
