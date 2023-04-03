# frozen_string_literal: true

require 'rails_helper'

feature "Managing a provider's schools", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_schools_page
    then_i_should_see_a_list_of_schools
  end

  describe 'add school' do
    scenario 'with valid details' do
      when_i_click_add_a_school
      then_i_can_add_a_school
    end
  end

  describe 'edit school' do
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
  end

  describe 'delete school' do
    scenario 'with no associated courses' do
      when_i_visit_the_publish_school_show_page
      and_i_click_remove_school_link
      then_i_am_on_the_school_delete_page
      when_i_click_cancel
      then_i_am_on_the_school_show_page

      and_i_click_remove_school_link
      and_i_click_remove_school_button
      then_i_am_on_the_index_page
      and_the_school_is_deleted
    end

    scenario 'with associcated course' do
      given_there_is_an_associated_course
      when_i_visit_the_publish_school_show_page
      and_i_click_remove_school_link
      then_i_am_on_the_school_delete_page
      and_i_cannot_delete_the_school
    end
  end

  def and_i_cannot_delete_the_school
    expect(publish_school_delete_page).to have_text('You cannot remove this school')
    expect(publish_school_delete_page).not_to have_remove_school_button
  end

  def given_there_is_an_associated_course
    @course = create(:course, provider:)
    @course.sites << @site
  end

  def and_the_school_is_deleted
    expect(provider.sites.count).to eq 0
  end

  def and_i_click_remove_school_button
    click_button 'Remove school'
  end

  def when_i_click_cancel
    click_link 'Cancel'
  end

  def then_i_am_on_the_school_delete_page
    # binding.pry
    expect(publish_school_delete_page).to be_displayed
  end

  def and_i_click_remove_school_link
    click_link 'Remove school'
  end

  def when_i_visit_the_publish_school_show_page
    publish_school_show_page.load(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, school_id: @site.id)
  end

  def and_the_school_is_not_updated
    @site.reload
    expect(@site.location_name).to include 'Main Site'
  end

  def then_i_see_an_error_message
    expect(publish_school_edit_page.error_summary).to have_text('Enter a name')
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

  def then_i_am_on_the_index_page
    expect(publish_schools_index_page).to be_displayed
  end

  def and_i_click_back
    click_link 'Back'
  end

  def and_the_school_is_updated
    expect(page).to have_text 'Test name'
    @site.reload
    expect(@site.location_name).to eq 'Test name'
  end

  def and_i_click_update
    click_button 'Update school'
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

  def then_i_am_on_the_school_show_page
    expect(publish_school_show_page).to be_displayed
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(:user, providers: [create(:provider, sites: [build(:site)])])
    )
  end

  def when_i_visit_the_schools_page
    publish_schools_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year
    )
  end

  def then_i_should_see_a_list_of_schools
    expect(publish_schools_index_page.schools.size).to eq(1)

    expect(publish_schools_index_page.schools.first.name).to have_text(site.location_name)
    expect(publish_schools_index_page.schools.first.code).to have_text(site.code)
    expect(publish_schools_index_page.schools.first.urn).to have_text(site.urn)
  end

  def when_i_click_add_a_school
    publish_schools_index_page.add_school.click
  end

  def then_i_can_add_a_school
    expect(page).to have_current_path publish_school_new_page.url(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year
    )

    publish_school_new_page.name_field.set 'Some place'
    publish_school_new_page.address1_field.set '123 Test Street'
    publish_school_new_page.address3_field.set 'London'
    publish_school_new_page.postcode_field.set 'KT8 9AU'
    publish_school_new_page.submit.click

    expect(publish_schools_index_page.schools.size).to eq(2)
    expect(publish_schools_index_page.schools.last.name).to have_text('Some place')
  end

  def when_i_click_on_a_school
    publish_schools_index_page.schools.last.edit_link.click
  end

  def then_i_can_update_its_details
    expect(page).to have_current_path publish_school_edit_page.url(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      school_id: Site.last.id
    )

    publish_school_edit_page.name_field.set 'Renamed place'
    publish_school_new_page.submit.click
    expect(publish_schools_index_page.schools.size).to eq(2)
    expect(publish_schools_index_page.schools.last.name).to have_text('Renamed place')
  end

  private

  def provider
    @current_user.providers.first
  end

  def site
    @site ||= provider.sites.first
  end
end
