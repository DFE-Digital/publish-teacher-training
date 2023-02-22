# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'SEND filter' do
  include FiltersFeatureSpecsHelper

  scenario 'Candidate applies the SEND filter' do
    when_i_visit_the_find_results_page
    then_i_see_that_the_send_checkbox_is_not_selected

    when_i_select_the_send_checkbox
    and_apply_the_filters
    then_i_see_that_the_send_checkbox_is_selected
    and_the_send_query_parameter_is_retained
  end

  def then_i_see_that_the_send_checkbox_is_not_selected
    expect(find_results_page.send.checkbox).not_to be_checked
  end

  def when_i_select_the_send_checkbox
    page.check('Only show courses with a SEND specialism')
  end

  def then_i_see_that_the_send_checkbox_is_selected
    expect(find_results_page.send.checkbox).to be_checked
  end

  def and_the_send_query_parameter_is_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')
      expect(uri.query).to eq('send_courses=true&has_vacancies=true&study_type[]=full_time&study_type[]=part_time&qualification[]=qts&qualification[]=pgce_with_qts&qualification[]=pgce+pgde&degree_required=show_all_courses')
    end
  end
end
