# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Results page new application open filter' do
  include FiltersFeatureSpecsHelper

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario 'Candidate applies applications open filter on results page' do
    when_i_visit_the_find_results_page
    then_i_see_the_applications_open_checkbox_is_selected

    when_i_unselect_the_applications_open_checkbox
    and_apply_the_filters
    then_i_see_that_the_applications_open_checkbox_is_still_unselected
    and_the_applications_open_query_parameters_are_retained
  end

  def then_i_see_the_applications_open_checkbox_is_selected
    expect(find_results_page.applications_open.checkbox).to be_checked
  end

  def when_i_unselect_the_applications_open_checkbox
    uncheck('Only show courses open for applications')
  end

  def then_i_see_that_the_applications_open_checkbox_is_still_unselected
    expect(find_results_page.applications_open.checkbox).not_to be_checked
  end

  def and_the_applications_open_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')
      expect(uri.query).to eq('study_type[]=full_time&study_type[]=part_time&qualification[]=qts&qualification[]=pgce_with_qts&qualification[]=pgce+pgde&degree_required=show_all_courses&applications_open=false')
    end
  end
end
