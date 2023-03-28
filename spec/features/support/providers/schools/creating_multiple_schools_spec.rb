# frozen_string_literal: true

require 'rails_helper'

feature 'Multiple schools' do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
  end

  scenario 'submitting an empty form' do
    and_the_multiple_schools_feature_flag_is_active
    when_i_visit_a_provider_schools_page
    then_i_click_add_multiple_schools

    given_i_submit_an_empty_form
    then_i_should_see_the_validation_error_message
  end

  scenario 'submitting a form with two schools' do
    and_the_multiple_schools_feature_flag_is_active
    when_i_visit_the_multiple_schools_new_page
    and_i_submit_the_form_with_two_schools
    and_i_see_the_text_one_of_two
    then_i_should_see_that_the_text_field_has_been_prepopulated('Name', 'Tottenham')

    given_i_submit_a_valid_form
    and_i_see_the_text_two_of_two
    and_i_see_that_the_text_field_has_been_prepopulated('Name', 'Tottenham Hotspur')
    and_i_submit_a_valid_form
    and_i_am_redirected_to_the_multiple_school_confirm_page
    then_the_database_should_not_have_updated_with_the_new_school

    given_i_add_the_schools
    when_i_am_redirected_to_the_schools_page
    and_i_see_the_text_two_schools_added
    then_the_database_should_have_updated_with_the_new_schools
  end

  scenario 'clicking back' do
    given_the_multiple_schools_feature_flag_is_active
    and_i_visit_the_multiple_schools_new_page
    and_i_submit_the_form_with_two_schools
    and_i_see_the_text_one_of_two
    and_i_should_see_that_the_text_field_has_been_prepopulated('Name', 'Tottenham')

    and_i_submit_a_valid_form
    and_i_see_the_text_two_of_two
    and_i_see_that_the_text_field_has_been_prepopulated('Name', 'Tottenham Hotspur')
    and_i_submit_a_valid_form
    and_i_am_redirected_to_the_multiple_school_confirm_page
    and_i_click_change
    and_the_text_field_is_prepopulated
    and_i_click_back
    and_i_am_redirected_to_the_multiple_school_confirm_page
    and_i_click_back
    and_i_submit_the_form
    and_i_am_redirected_to_the_multiple_school_confirm_page
    and_the_database_should_not_have_updated_with_the_new_school

    when_i_click_back
    then_i_see_the_text_two_of_two
    and_i_see_that_the_text_field_has_been_prepopulated('Name', 'Tottenham Hotspur')
    and_i_click_back
    and_i_see_the_text_one_of_two
    and_i_should_see_that_the_text_field_has_been_prepopulated('Name', 'Tottenham')

    and_i_click_back
    and_i_am_on_the_new_multiple_schools_page

    and_i_click_back

    and_i_should_be_on_the_provider_schools_page
  end

  scenario 'cancel from multiple schools new page' do
    given_the_multiple_schools_feature_flag_is_active
    and_i_visit_the_multiple_schools_new_page

    when_i_click_cancel
    then_i_should_be_on_the_provider_schools_page
  end

  scenario 'cancel from multiple schools new page for a school' do
    given_the_multiple_schools_feature_flag_is_active
    and_i_visit_the_multiple_schools_new_page
    and_i_submit_the_form_with_two_schools
    and_i_see_the_text_one_of_two
    and_i_should_see_that_the_text_field_has_been_prepopulated('Name', 'Tottenham')

    when_i_click_cancel
    then_i_should_be_on_the_provider_schools_page
  end

  scenario 'cancel from multiple school confirm page' do
    given_the_multiple_schools_feature_flag_is_active
    and_i_visit_the_multiple_schools_new_page
    and_i_submit_the_form_with_two_schools
    and_i_submit_a_valid_form
    and_i_see_the_text_two_of_two
    and_i_see_that_the_text_field_has_been_prepopulated('Name', 'Tottenham Hotspur')
    and_i_submit_a_valid_form
    and_i_am_redirected_to_the_multiple_school_confirm_page

    when_i_click_cancel
    then_i_should_be_on_the_provider_schools_page
  end

  def and_i_click_change
    page.all('.govuk-summary-card__action')[1].click_link
  end

  def and_the_text_field_is_prepopulated
    expect(page).to have_field('Name', with: 'Tottenham Hotspur')
  end

  def then_the_database_should_have_updated_with_the_new_schools
    expect(Site.exists?(location_name: 'Tottenham')).to be true
    expect(Site.exists?(location_name: 'Tottenham Hotspur')).to be true
  end

  def then_the_database_should_not_have_updated_with_the_new_school
    expect(Site.exists?(location_name: 'Tottenham')).to be false
    expect(Site.exists?(location_name: 'Tottenham Hotspur')).to be false
  end

  def and_i_see_the_text_two_schools_added
    expect(page).to have_text('2 schools added')
  end

  def and_i_am_redirected_to_the_multiple_school_confirm_page
    expect(page).to have_current_path support_recruitment_cycle_provider_schools_multiple_check_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
    expect(page).to have_text 'Check your answers'
  end

  def then_i_should_see_that_the_text_field_has_been_prepopulated(name, text)
    expect(page).to have_field(name, with: text)
  end

  def given_i_submit_a_valid_form
    fill_in 'Address line 1', with: '782 High Road'
    fill_in 'Town or city', with: 'London'
    fill_in 'Postcode', with: 'N17 0BX'
    click_continue
  end

  def and_i_see_the_text_one_of_two
    expect(page).to have_text 'Add school (1 of 2)'
  end

  def and_i_see_the_text_two_of_two
    expect(page).to have_text 'Add school (2 of 2)'
  end

  def and_i_submit_the_form_with_two_schools
    fill_in 'School details', with: "Tottenham\nTottenham Hotspur"
    click_continue
  end

  def when_i_visit_the_multiple_schools_new_page
    visit new_support_recruitment_cycle_provider_schools_multiple_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def when_i_visit_a_provider_schools_page
    visit support_recruitment_cycle_provider_schools_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def provider
    @provider ||= create(:provider, sites: [build(:site)])
  end

  def and_the_multiple_schools_feature_flag_is_active
    allow(Settings.features).to receive(:add_multiple_schools).and_return(true)
  end

  def then_i_click_add_multiple_schools
    click_link 'Add multiple schools'
  end

  def given_i_submit_an_empty_form
    click_button 'Continue'
  end

  def when_i_click_back
    click_link 'Back'
  end

  def when_i_click_cancel
    click_link 'Cancel'
  end

  def given_i_add_the_schools
    click_button 'Add schools'
  end

  def then_i_should_see_the_validation_error_message
    expect(page).to have_text('Enter school details')
  end

  def when_i_am_redirected_to_the_schools_page
    expect(page).to have_current_path support_recruitment_cycle_provider_schools_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def and_i_am_on_the_new_multiple_schools_page
    expect(page).to have_current_path new_support_recruitment_cycle_provider_schools_multiple_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  alias_method :and_i_click_back, :when_i_click_back

  alias_method :then_i_see_the_text_two_of_two, :and_i_see_the_text_two_of_two
  alias_method :and_i_should_see_that_the_text_field_has_been_prepopulated, :then_i_should_see_that_the_text_field_has_been_prepopulated
  alias_method :and_i_visit_the_multiple_schools_new_page, :when_i_visit_the_multiple_schools_new_page
  alias_method :and_the_database_should_not_have_updated_with_the_new_school, :then_the_database_should_not_have_updated_with_the_new_school
  alias_method :given_the_multiple_schools_feature_flag_is_active, :and_the_multiple_schools_feature_flag_is_active

  alias_method :then_i_should_be_on_the_provider_schools_page, :when_i_am_redirected_to_the_schools_page
  alias_method :and_i_should_be_on_the_provider_schools_page, :when_i_am_redirected_to_the_schools_page
  alias_method :and_i_submit_a_valid_form, :given_i_submit_a_valid_form
  alias_method :and_i_see_that_the_text_field_has_been_prepopulated, :then_i_should_see_that_the_text_field_has_been_prepopulated
  alias_method :click_continue, :given_i_submit_an_empty_form
  alias_method :and_i_submit_the_form, :given_i_submit_an_empty_form
end
