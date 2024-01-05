# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Engineers teach physics' do
  include FiltersFeatureSpecsHelper

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_i_visit_the_search_by_location_or_provider_page
    given_i_choose_across_england
    given_i_choose_secondary
  end

  scenario 'Candidate searches for physics subject' do
    given_i_choose_physics
    and_i_provide_my_visa_status
    then_i_see_that_the_etp_checkbox_is_unchecked
  end

  scenario 'Candidate searches for any other subject' do
    given_i_choose_music
    and_i_provide_my_visa_status
    then_i_dont_see_the_etp_checkbox
  end

  def given_i_visit_the_search_by_location_or_provider_page
    find_courses_by_location_or_training_provider_page.load
  end

  def given_i_choose_across_england
    find_courses_by_location_or_training_provider_page.across_england.choose
    find_courses_by_location_or_training_provider_page.continue.click
  end

  def given_i_choose_secondary
    find_age_groups_page.secondary.choose
    find_age_groups_page.continue.click
  end

  def given_i_choose_physics
    check 'Physics'
    find_secondary_subjects_page.continue.click
  end

  def given_i_choose_music
    check 'Chemistry'
    find_secondary_subjects_page.continue.click
  end

  def and_i_provide_my_visa_status
    choose 'Yes'
    click_button 'Find courses'
  end

  def then_i_see_that_the_etp_checkbox_is_unchecked
    expect(find_results_page.engineers_teach_physics_filter.legend.text).to eq('Engineers teach physics')
    expect(find_results_page.engineers_teach_physics_filter.checkbox.checked?).to be(false)
    expect(find_results_page).to have_text('Only show Engineers teach physics courses')
  end

  def then_i_dont_see_the_etp_checkbox
    expect(find_results_page).to have_no_text('Only show Engineers teach physics courses')
  end
end
