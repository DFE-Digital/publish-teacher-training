# frozen_string_literal: true

module FiltersFeatureSpecsHelper
  def results_page
    @results_page ||= PageObjects::Find::Results.new
  end

  def when_i_visit_the_results_page
    create_list(:course, 5)
    results_page.load
  end

  def and_apply_the_filters
    results_page.apply_filters_button.click
  end
end
