# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Funding filter' do
  include FiltersFeatureSpecsHelper

  scenario 'Candidate applies salary filter' do
    when_i_visit_the_find_results_page
    then_i_see_that_the_salary_checkbox_is_not_selected

    when_i_select_the_salary_checkbox
    and_apply_the_filters
    then_i_see_that_the_salary_checkbox_is_selected
    and_the_salary_query_parameter_is_retained
  end

  def then_i_see_that_the_salary_checkbox_is_not_selected
    expect(find_results_page.funding.checkbox).not_to be_checked
  end

  def when_i_select_the_salary_checkbox
    check('Only show courses that come with a salary')
  end

  def then_i_see_that_the_salary_checkbox_is_selected
    expect(find_results_page.funding.checkbox).to be_checked
  end

  def and_the_salary_query_parameter_is_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')
      expect(uri.query).to eq('has_vacancies=true&study_type[]=full_time&study_type[]=part_time&qualification[]=qts&qualification[]=pgce_with_qts&qualification[]=pgce+pgde&degree_required=show_all_courses&funding=salary')
    end
  end
end
