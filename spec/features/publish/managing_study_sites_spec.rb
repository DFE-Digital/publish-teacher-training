# frozen_string_literal: true

require 'rails_helper'

feature "Managing a provider's study_sites", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_study_sites_page
    then_i_should_see_a_list_of_study_sites
  end

  describe 'add study site' do
    scenario 'with valid details' do
      add_study_site_with_valid_details
    end

    scenario 'with existing name' do
      add_study_site_with_valid_details
      when_i_click_add_study_site
      and_i_click_the_link_to_enter_a_school_manually
      and_i_set_existing_name_details
      then_i_see_an_error_message('Name is in use by another location')
      and_the_study_site_is_not_added
    end

    scenario 'with invalid details' do
      when_i_click_add_study_site
      and_i_click_the_link_to_enter_a_school_manually
      and_i_set_invalid_new_details
      then_i_see_an_error_message('Enter a name')
    end
  end

  describe 'edit study site' do
    scenario 'with valid details' do
      when_i_click_on_a_study_site
      and_i_am_on_the_study_sites_show_page
      and_i_click_a_change_link
      and_i_change_the_name
      and_the_updated_site_is_displayed
      and_i_click_back
      then_i_am_on_the_index_page
      and_the_updated_site_is_displayed
    end

    scenario 'with invalid details' do
      when_i_click_on_a_study_site
      and_i_click_a_change_link
      and_i_enter_invalid_details
      then_i_see_an_error_message('Enter address line 1')
    end
  end

  describe 'delete study site' do
    scenario 'with no associated courses' do
      when_i_click_on_a_study_site
      and_i_click_to_remove
      then_i_am_on_the_study_sites_delete_page
      when_i_click_cancel
      then_i_am_on_the_study_site_show_page

      and_i_click_to_remove
      and_i_click_the_remove_study_site_button
      then_i_am_on_the_index_page
      and_the_study_site_is_deleted
    end

    scenario 'with associcated course' do
      given_there_is_an_associated_course
      when_i_click_on_a_study_site
      and_i_click_to_remove
      then_i_am_on_the_study_sites_delete_page
      and_i_cannot_delete_the_study_site
    end
  end

  def and_i_click_back
    click_link_or_button 'Back'
  end

  def and_i_enter_invalid_details
    fill_in('Address line 1', with: '')
    click_link_or_button 'Update study site'
  end

  def and_the_updated_site_is_displayed
    expect(page).to have_text('Hogwarts')
  end

  def and_i_change_the_name
    fill_in('Study site name', with: 'Hogwarts')
    click_link_or_button 'Update study site'
  end

  def and_i_click_a_change_link
    click_link_or_button(class: 'govuk-link location_name')
  end

  def and_i_am_on_the_study_sites_show_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/study-sites/#{site.id}")
  end
  alias_method :then_i_am_on_the_study_site_show_page, :and_i_am_on_the_study_sites_show_page

  def when_i_click_on_a_study_site
    click_link_or_button site.location_name
  end

  def add_study_site_with_valid_details
    when_i_click_add_study_site
    and_i_click_the_link_to_enter_a_school_manually
    and_i_set_valid_new_details
    and_i_am_on_the_study_sites_check_page
    and_i_click_add_study_site
    then_i_am_on_the_index_page
    and_the_study_site_is_added
  end

  def and_the_study_site_is_not_added
    expect(provider.study_sites.count).to eq 2
  end

  def then_i_see_an_error_message(msg)
    expect(page).to have_text(msg)
  end

  def and_the_study_site_is_added
    expect(page).to have_css('tbody.govuk-table__body tr', count: 2)
    expect(page).to have_text(site.location_name)
    expect(page).to have_text('Some place')
  end

  def then_i_am_on_the_index_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/study-sites")
  end

  def and_i_click_add_study_site
    click_link_or_button 'Add study site'
  end

  def and_i_am_on_the_study_sites_check_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/study-sites/check")
  end

  def and_i_click_the_link_to_enter_a_school_manually
    click_link_or_button 'I cannot find the school - enter manually'
  end

  def and_i_set_valid_new_details
    page.fill_in 'Study site name', with: 'Some place'
    page.fill_in 'Address line 1', with: '123 Test Street'
    page.fill_in 'Town or city', with: 'London'
    page.fill_in 'Postcode', with: 'KT8 9AU'
    click_link_or_button 'Continue'
  end

  def and_i_set_invalid_new_details
    page.fill_in 'Study site name', with: ''
    page.fill_in 'Address line 1', with: '123 Test Street'
    page.fill_in 'Town or city', with: 'London'
    page.fill_in 'Postcode', with: 'KT8 9AU'
    click_link_or_button 'Continue'
  end

  def and_i_set_existing_name_details
    page.fill_in 'Study site name', with: 'Some place'
    page.fill_in 'Address line 1', with: 'Another Test Street'
    page.fill_in 'Town or city', with: 'Manchester'
    page.fill_in 'Postcode', with: 'M16 0RA'
    click_link_or_button 'Continue'
  end

  def when_i_click_add_study_site
    click_link_or_button 'Add study site'
  end

  def then_i_should_see_a_list_of_study_sites
    expect(page).to have_css('tbody.govuk-table__body tr', count: 1)
    expect(page).to have_text(site.location_name)
    expect(page).to have_text(site.urn)
  end

  def when_i_visit_the_study_sites_page
    visit publish_provider_recruitment_cycle_study_sites_path(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year
    )
  end

  def and_i_click_add_school
    click_link_or_button 'Add school'
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(:user, providers: [create(:provider, sites: [build(:site, :study_site)])])
    )
  end

  def and_i_click_to_remove
    click_link_or_button 'Remove study site'
  end

  def then_i_am_on_the_study_sites_delete_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/study-sites/#{site.id}/delete")
  end

  def when_i_click_cancel
    click_link_or_button 'Cancel'
  end

  def and_i_click_the_remove_study_site_button
    click_link_or_button 'Remove study site'
  end

  def and_the_study_site_is_deleted
    expect(provider.study_sites.count).to eq 0
  end

  def given_there_is_an_associated_course
    @course = create(:course, provider:)
    @course.study_sites << @site
  end

  def and_i_cannot_delete_the_study_site
    expect(page).to have_content('You cannot remove this study site')
    expect(page).to have_no_button('Remove study site')
  end

  private

  def provider
    @current_user.providers.first
  end

  def site
    @site ||= provider.study_sites.first
  end
end
