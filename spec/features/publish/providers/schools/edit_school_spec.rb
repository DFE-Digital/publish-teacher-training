# frozen_string_literal: true

require 'rails_helper'
require_relative 'provider_school_helper'

feature "Editing a provider's schools", { can_edit_current_and_next_cycles: false } do
  include ProviderSchoolHelper
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_schools_page
    then_i_should_see_a_list_of_schools
  end

  scenario 'with valid details' do
    when_i_click_on_a_school
    then_i_am_on_the_school_show_page
    and_i_click_change_name
    then_i_am_on_the_school_edit_page
    and_i_change_school_details
    and_i_click_update
    then_i_am_on_the_school_show_page
    and_the_school_is_updated
    and_i_click_back
    then_i_am_on_the_index_page
  end

  scenario 'with invalid details' do
    when_i_visit_the_publish_school_edit_page
    and_i_set_invalid_details
    and_i_click_update
    then_i_see_an_error_message
    and_the_school_is_not_updated
  end

  def and_the_school_is_not_updated
    @site.reload
    expect(@site.location_name).to include 'Main Site'
  end

  def and_i_set_invalid_details
    publish_school_edit_page
      .school_form
      .location_name
      .set('')
  end

  def when_i_visit_the_publish_school_edit_page
    publish_school_edit_page.load(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, school_id: @site.id)
  end

  def and_i_click_back
    click_link_or_button 'Back'
  end

  def and_the_school_is_updated
    expect(page).to have_text 'Test name'
    @site.reload
    expect(@site.location_name).to eq 'Test name'
  end

  def and_i_click_update
    click_link_or_button 'Update school'
  end

  def and_i_change_school_details
    publish_school_edit_page
      .school_form
      .location_name
      .set('Test name')
  end

  def then_i_am_on_the_school_edit_page
    expect(publish_school_edit_page).to be_displayed
  end

  def and_i_click_change_name
    publish_school_show_page.change_name.click
  end

  def when_i_click_on_a_school
    publish_schools_index_page.schools.last.edit_link.click
  end
end
