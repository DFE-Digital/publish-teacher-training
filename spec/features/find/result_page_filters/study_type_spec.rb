# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Study type filter' do
  include FiltersFeatureSpecsHelper

  scenario 'Candidate applies study type filters on results page' do
    when_i_visit_the_find_results_page
    then_i_see_both_study_type_checkboxes_are_selected

    when_i_unselect_the_part_time_study_checkbox
    and_apply_the_filters
    then_i_see_that_the_full_time_study_checkbox_is_still_selected
    and_the_part_time_study_checkbox_is_unselected
    and_the_full_time_study_query_parameters_are_retained

    when_i_unselect_the_full_time_study_checkbox
    and_i_select_the_part_time_study_checkbox
    and_apply_the_filters
    then_i_see_that_the_part_time_study_checkbox_is_still_selected
    and_the_full_time_study_checkbox_is_unselected
    and_the_part_time_study_query_parameters_are_retained
  end

  def then_i_see_both_study_type_checkboxes_are_selected
    expect(find_results_page.study_type.part_time).to be_checked
    expect(find_results_page.study_type.full_time).to be_checked
  end

  def when_i_unselect_the_part_time_study_checkbox
    uncheck('Part time (18 to 24 months)')
  end

  def then_i_see_that_the_full_time_study_checkbox_is_still_selected
    expect(find_results_page.study_type.full_time).to be_checked
  end

  def and_the_part_time_study_checkbox_is_unselected
    expect(find_results_page.study_type.part_time).not_to be_checked
  end

  def and_the_full_time_study_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')
      expect(uri.query).to eq('study_type[]=full_time&qualification[]=qts&qualification[]=pgce_with_qts&qualification[]=pgce+pgde&degree_required=show_all_courses&applications_open=true')
    end
  end

  def when_i_unselect_the_full_time_study_checkbox
    uncheck('Full time (12 months)')
  end

  def and_i_select_the_part_time_study_checkbox
    find_results_page.study_type.part_time.check
  end

  def then_i_see_that_the_part_time_study_checkbox_is_still_selected
    expect(find_results_page.study_type.part_time).to be_checked
  end

  def and_the_full_time_study_checkbox_is_unselected
    expect(find_results_page.study_type.full_time).not_to be_checked
  end

  def and_the_part_time_study_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')
      expect(uri.query).to eq('study_type[]=part_time&qualification[]=qts&qualification[]=pgce_with_qts&qualification[]=pgce+pgde&degree_required=show_all_courses&applications_open=true')
    end
  end
end
