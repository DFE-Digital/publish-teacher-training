# frozen_string_literal: true

module FiltersFeatureSpecsHelper
  def when_i_visit_the_find_results_page
    create_list(:course, 5)
    find_results_page.load
  end

  def and_apply_the_filters
    find_results_page.apply_filters_button.click
  end
end
