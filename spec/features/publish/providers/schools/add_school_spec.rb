# frozen_string_literal: true

require 'rails_helper'
require_relative 'provider_school_helper'

feature "Adding a provider's schools", { can_edit_current_and_next_cycles: false } do
  include ProviderSchoolHelper
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_schools_page
    then_i_should_see_a_list_of_schools
  end

  scenario 'with valid details' do
    given_i_see_the_schools_guidance_text
    when_i_click_add_a_school
    and_i_click_the_link_to_enter_a_school_manually
    and_i_set_valid_new_details
    and_i_am_on_the_schools_check_page
    and_i_click_add_school
    then_i_am_on_the_index_page
    and_the_school_is_added
  end

  scenario 'with invalid details' do
    when_i_click_add_a_school
    and_i_click_the_link_to_enter_a_school_manually
    and_i_set_invalid_new_details
    then_i_see_an_error_message
    and_the_school_is_not_added
  end

  def given_i_see_the_schools_guidance_text
    expect(page).to have_text('Add the schools you can offer placements in. A placement school is where candidates will go to get classroom experience.', normalize_ws: true)
    expect(page).to have_text('Your courses will not appear in candidate’s location searches if you do not add placement schools to them.', normalize_ws: true)
    expect(page).to have_link('Find out more about why you should add school placement locations', href: 'https://www.publish-teacher-training-courses.service.gov.uk/how-to-use-this-service/add-schools-and-study-sites')
    expect(page).to have_text('Add placement schools here, then attach them to any of your courses from the ‘Basic details’ tab on each course page.', normalize_ws: true)
  end

  def when_i_click_add_a_school
    publish_schools_index_page.add_school.click
  end

  def and_i_click_the_link_to_enter_a_school_manually
    click_link_or_button 'I cannot find the school - enter manually'
  end

  def and_i_set_valid_new_details
    publish_school_new_page.name_field.set 'Some place'
    publish_school_new_page.address1_field.set '123 Test Street'
    publish_school_new_page.town_field.set 'London'
    publish_school_new_page.postcode_field.set 'KT8 9AU'
    publish_school_new_page.submit.click
  end

  def and_i_am_on_the_schools_check_page
    expect(publish_provider_schools_check_page).to be_displayed
  end

  def and_i_click_add_school
    click_link_or_button 'Add school'
  end

  def and_the_school_is_added
    expect(publish_schools_index_page.schools.size).to eq(2)
    expect(publish_schools_index_page.schools.last.name).to have_text('Some place')
  end

  def and_i_set_invalid_new_details
    publish_school_new_page.name_field.set ''
    publish_school_new_page.address1_field.set '123 Test Street'
    publish_school_new_page.town_field.set 'London'
    publish_school_new_page.postcode_field.set 'KT8 9AU'
    publish_school_new_page.submit.click
  end

  def and_the_school_is_not_added
    expect(Site.count).to eq(1)
  end
end
