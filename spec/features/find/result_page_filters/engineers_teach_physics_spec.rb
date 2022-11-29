require "rails_helper"

RSpec.feature "Engineers teach physics" do
  include FiltersFeatureSpecsHelper

  before do
    given_i_visit_the_search_by_location_or_provider_page
    given_i_choose_across_england
    given_i_choose_secondary
  end

  scenario "Candidate searches for physics subject" do
    given_i_choose_physics
    then_i_see_that_the_etp_checkbox_is_unchecked
  end

  scenario "Candidate searches for any other subject" do
    given_i_choose_music
    then_i_dont_see_the_etp_checkbox
  end

  def given_i_visit_the_search_by_location_or_provider_page
    courses_by_location_or_training_provider_page.load
  end

  def given_i_choose_across_england
    courses_by_location_or_training_provider_page.across_england.choose
    courses_by_location_or_training_provider_page.continue.click
  end

  def given_i_choose_secondary
    age_groups_page.secondary.choose
    age_groups_page.continue.click
  end

  def given_i_choose_physics
    check "Physics"
    secondary_subjects_page.continue.click
  end

  def given_i_choose_music
    check "Chemistry"
    secondary_subjects_page.continue.click
  end

  def then_i_see_that_the_etp_checkbox_is_unchecked
    expect(results_page.engineers_teach_physics_filter.legend.text).to eq("Engineers teach physics")
    expect(results_page.engineers_teach_physics_filter.checkbox.checked?).to be(false)
    expect(results_page).to have_text("Only show Engineers teach physics courses")
  end

  def then_i_dont_see_the_etp_checkbox
    expect(results_page).not_to have_text("Only show Engineers teach physics courses")
  end
end
