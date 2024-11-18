# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Qualifications filter' do
  include FiltersFeatureSpecsHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario 'Candidate applies qualifications filters on results page' do
    when_i_visit_the_find_results_page
    then_i_see_all_qualifications_checkboxes_are_not_selected

    when_i_select_all_qualifications
    and_apply_the_filters
    then_i_see_all_qualifications_checkboxes_are_selected
    and_all_qualification_query_parameters_are_added

    when_i_unselect_the_pgce_and_further_education_qualification_checkboxes
    and_apply_the_filters
    then_i_see_that_the_pgce_and_further_education_qualification_checkboxes_are_still_unselected
    and_the_qts_checkbox_is_selected
    and_the_qts_qualification_query_parameters_are_retained

    when_i_select_the_pgce_checkbox
    and_i_deselect_the_qts_checkbox
    and_apply_the_filters
    then_i_see_that_the_qts_and_further_education_checkboxes_are_still_unselected
    and_the_pgce_checkbox_is_selected
    and_the_pgce_qualification_query_parameters_are_retained

    when_i_select_the_further_education_checkbox
    and_i_deselect_the_pgce_checkbox
    and_apply_the_filters
    then_i_see_that_the_pgce_and_qts_checkboxes_are_still_unselected
    and_the_further_education_checkbox_is_selected
    and_the_further_education_qualification_query_parameters_are_retained
  end

  def then_i_see_all_qualifications_checkboxes_are_selected
    expect(find_results_page.qualifications.qts).to be_checked
    expect(find_results_page.qualifications.pgce_with_qts).to be_checked
    expect(find_results_page.qualifications.other).to be_checked
  end

  def then_i_see_all_qualifications_checkboxes_are_not_selected
    expect(find_results_page.qualifications.qts).not_to be_checked
    expect(find_results_page.qualifications.pgce_with_qts).not_to be_checked
    expect(find_results_page.qualifications.other).not_to be_checked
  end

  def when_i_select_all_qualifications
    check 'QTS only'
    check 'QTS with PGCE (or PGDE)'
    check 'Further education (PGCE or PGDE without QTS)'
  end

  def when_i_unselect_the_pgce_and_further_education_qualification_checkboxes
    uncheck('QTS with PGCE (or PGDE)')
    uncheck('Further education (PGCE or PGDE without QTS)')
  end

  def and_the_qts_checkbox_is_selected
    expect(find_results_page.qualifications.qts).to be_checked
  end

  def and_the_pgce_checkbox_is_selected
    expect(find_results_page.qualifications.pgce_with_qts).to be_checked
  end

  def and_the_further_education_checkbox_is_selected
    expect(find_results_page.qualifications.other).to be_checked
  end

  def then_i_see_that_the_qts_and_further_education_checkboxes_are_still_unselected
    expect(find_results_page.qualifications.qts_checkbox).to be_checked
    expect(find_results_page.qualifications.further_education_checkbox).to be_checked
  end

  def then_i_see_that_the_pgce_and_further_education_qualification_checkboxes_are_still_unselected
    expect(find_results_page.qualifications.pgce_with_qts).not_to be_checked
    expect(find_results_page.qualifications.other).not_to be_checked
  end

  def then_i_see_that_the_pgce_and_qts_checkboxes_are_still_unselected
    expect(find_results_page.qualifications.pgce_with_qts).not_to be_checked
    expect(find_results_page.qualifications.qts).not_to be_checked
  end

  def and_all_qualification_query_parameters_are_added
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')

      expected_params = {
        'qualification' => ['qts', 'pgce_with_qts', 'pgce pgde'],
        'degree_required' => 'show_all_courses',
        'applications_open' => 'true'
      }

      expect(query_params(uri)).to eq(expected_params)
    end
  end

  def and_the_qts_qualification_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')

      expected_params = {
        'qualification' => ['qts'],
        'degree_required' => 'show_all_courses',
        'applications_open' => 'true'
      }

      expect(query_params(uri)).to eq(expected_params)
    end
  end

  def and_the_pgce_qualification_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')

      expected_params = {
        'qualification' => ['pgce_with_qts'],
        'degree_required' => 'show_all_courses',
        'applications_open' => 'true'
      }

      expect(query_params(uri)).to eq(expected_params)
    end
  end

  def and_the_further_education_qualification_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')

      expected_params = {
        'qualification' => ['pgce pgde'],
        'degree_required' => 'show_all_courses',
        'applications_open' => 'true'
      }

      expect(query_params(uri)).to eq(expected_params)
    end
  end

  def when_i_select_the_pgce_checkbox
    check('QTS with PGCE (or PGDE)')
  end

  def when_i_select_the_further_education_checkbox
    check('Further education (PGCE or PGDE without QTS)')
  end

  def and_i_deselect_the_qts_checkbox
    uncheck('QTS only')
  end

  def and_i_deselect_the_pgce_checkbox
    uncheck('QTS with PGCE (or PGDE)')
  end

  def then_i_see_that_the_qts_and_further_education_checkboxes_are_still_unselected
    expect(find_results_page.qualifications.qts).not_to be_checked
    expect(find_results_page.qualifications.other).not_to be_checked
  end

  def then_i_see_that_the_qts_and_further_education_checkboxes_are_still_unselected
    expect(find_results_page.qualifications.qts).not_to be_checked
    expect(find_results_page.qualifications.other).not_to be_checked
  end
end
