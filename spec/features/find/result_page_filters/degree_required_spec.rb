# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Degree required filter' do
  include FiltersFeatureSpecsHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario 'Candidate applies required degree filters on results page' do
    when_i_visit_the_find_results_page
    then_i_see_the_two_one_degree_radio_checked

    when_i_select_the_two_two_degree_radio
    and_apply_the_filters
    then_i_see_that_the_two_two_degree_radio_is_selected
    and_the_two_two_degree_query_parameters_are_retained

    when_i_select_the_third_degree_radio
    and_apply_the_filters
    then_i_see_that_the_third_degree_radio_is_selected
    and_the_third_degree_query_parameters_are_retained

    when_i_select_the_pass_degree_radio
    and_apply_the_filters
    then_i_see_that_the_pass_degree_radio_is_selected
    and_the_pass_degree_query_parameters_are_retained
  end

  def then_i_see_the_two_one_degree_radio_checked
    expect(find_results_page.degree_grade.show_all_courses.checked?).to be(true)
  end

  def when_i_select_the_two_two_degree_radio
    choose('2:2')
  end

  def when_i_select_the_third_degree_radio
    choose('Third')
  end

  def when_i_select_the_pass_degree_radio
    choose('Pass (Ordinary degree)')
  end

  def then_i_see_that_the_two_two_degree_radio_is_selected
    expect(find_results_page.degree_grade.two_two).to be_checked
  end

  def then_i_see_that_the_third_degree_radio_is_selected
    expect(find_results_page.degree_grade.third_class).to be_checked
  end

  def then_i_see_that_the_pass_degree_radio_is_selected
    expect(find_results_page.degree_grade.not_required).to be_checked
  end

  def and_the_two_two_degree_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')

      expected_params = {
        'degree_required' => 'two_two',
        'applications_open' => 'true'
      }

      expect(query_params(uri)).to eq(expected_params)
    end
  end

  def and_the_third_degree_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')

      expected_params = {
        'degree_required' => 'third_class',
        'applications_open' => 'true'
      }

      expect(query_params(uri)).to eq(expected_params)
    end
  end

  def and_the_pass_degree_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')

      expected_params = {
        'degree_required' => 'not_required',
        'applications_open' => 'true'
      }

      expect(query_params(uri)).to eq(expected_params)
    end
  end
end
