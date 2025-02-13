# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Visa filter' do
  include FiltersFeatureSpecsHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario 'Candidate applies visa filter' do
    when_i_visit_the_find_results_page
    then_i_see_that_the_visa_checkbox_is_unchecked

    when_i_select_the_visa_checkbox
    and_apply_the_filters
    then_i_see_that_the_visa_checkbox_is_selected
    and_the_visa_query_parameter_is_retained
  end

  def then_i_see_that_the_visa_checkbox_is_unchecked
    expect(find_results_page.visa.checkbox).not_to be_checked
  end

  def when_i_select_the_visa_checkbox
    check('Only show courses with visa sponsorship')
  end

  def then_i_see_that_the_visa_checkbox_is_selected
    expect(find_results_page.visa.checkbox).to be_checked
  end

  def and_the_visa_query_parameter_is_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')

      expected_params = {
        'can_sponsor_visa' => 'true',
        'degree_required' => 'show_all_courses',
        'applications_open' => 'true'
      }

      expect(query_params(uri)).to eq(expected_params)
    end
  end
end
