# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Qualifications filter' do
  include FiltersFeatureSpecsHelper

  scenario 'Candidate applies qualifications filters on results page' do
    when_i_visit_the_find_results_page
    then_i_see_all_qualifications_checkboxes_are_selected

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

  def when_i_unselect_the_pgce_and_further_education_qualification_checkboxes
    uncheck('PGCE (or PGDE) with QTS')
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

  def and_the_qts_qualification_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')
      expect(uri.query).to eq('applications_open=true&study_type[]=full_time&study_type[]=part_time&qualification[]=qts&degree_required=show_all_courses')
    end
  end

  def and_the_pgce_qualification_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')
      expect(uri.query).to eq('applications_open=true&study_type[]=full_time&study_type[]=part_time&qualification[]=pgce_with_qts&degree_required=show_all_courses')
    end
  end

  def and_the_further_education_qualification_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')
      expect(uri.query).to eq('applications_open=true&study_type[]=full_time&study_type[]=part_time&qualification[]=pgce+pgde&degree_required=show_all_courses')
    end
  end

  def when_i_select_the_pgce_checkbox
    check('PGCE (or PGDE) with QTS')
  end

  def when_i_select_the_further_education_checkbox
    check('Further education (PGCE or PGDE without QTS)')
  end

  def and_i_deselect_the_qts_checkbox
    uncheck('QTS only')
  end

  def and_i_deselect_the_pgce_checkbox
    uncheck('PGCE (or PGDE) with QTS')
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
