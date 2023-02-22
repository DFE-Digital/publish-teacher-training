# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Results page new vacancies filter' do
  include FiltersFeatureSpecsHelper

  scenario 'Candidate applies vacancies filter on results page' do
    when_i_visit_the_find_results_page
    then_i_see_the_vacancies_checkbox_is_selected

    when_i_unselect_the_vacancies_checkbox
    and_apply_the_filters
    then_i_see_that_the_vacancies_checkbox_is_still_unselected
    and_the_vacancies_query_parameters_are_retained
  end

  def then_i_see_the_vacancies_checkbox_is_selected
    expect(find_results_page.vacancies.checkbox).to be_checked
  end

  def when_i_unselect_the_vacancies_checkbox
    page.uncheck('Only show courses with vacancies')
  end

  def then_i_see_that_the_vacancies_checkbox_is_still_unselected
    expect(find_results_page.vacancies.checkbox).not_to be_checked
  end

  def and_the_vacancies_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')
      expect(uri.query).to eq('has_vacancies=false&study_type[]=full_time&study_type[]=part_time&qualification[]=qts&qualification[]=pgce_with_qts&qualification[]=pgce+pgde&degree_required=show_all_courses')
    end
  end
end
