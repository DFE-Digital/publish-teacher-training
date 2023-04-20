# frozen_string_literal: true

class SearchResultTitleComponent < ViewComponent::Base
  include ActiveSupport::NumberHelper

  def initialize(query:, results_limit:, results_count:, return_path:, resource_name:)
    @query = query
    @results_limit = results_limit
    @results_count = results_count
    @return_path = return_path
    @resource_name = resource_name
    super
  end

  def title
    [
      count_text,
      found_text,
      query_text
    ].compact.join(' ')
  end

  def caption_text = "Add #{resource_name}"

  def results_text
    return many_results_text if results_count > results_limit
    return "#{change_your_search_link}.".html_safe if results_count.zero?

    "#{change_your_search_link} if the #{resource_name} you’re looking for is not listed.".html_safe
  end

  private

  attr_reader :query, :results_limit, :results_count, :return_path, :resource_name

  def count_text
    return number_to_delimited(results_count) if results_count >= 1

    'No'
  end

  def found_text
    return 'result found' if results_count == 1

    'results found'
  end

  def query_text
    return "for ‘#{query}’" if query.present?

    'for your search'
  end

  def many_results_text
    t('.many_results_html', link: govuk_link_to('Try narrowing down your search', return_path))
  end

  def change_your_search_link
    govuk_link_to('Change your search', return_path)
  end
end
