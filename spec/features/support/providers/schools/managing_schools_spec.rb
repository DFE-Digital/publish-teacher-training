# frozen_string_literal: true

require 'rails_helper'

feature "Managing a provider's schools" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    when_i_visit_a_provider_schools_page
  end

  scenario "i can view a provider's schools" do
    then_i_should_see_a_list_of_schools
  end

  # TODO: remove this
  # scenario 'i can add a new school' do
  #  and_i_click_on_the_add_school_link
  #  then_should_be_on_the_create_page_for_the_school
  #  when_i_add_the_school_details
  #  and_i_submit_for(support_provider_school_create_page)
  #  then_i_should_see_a_success_message_for(:created)
  #  and_the_new_school_should_show_in_the_list
  # end

  scenario "i can edit a provider's schools" do
    and_i_click_on_the_edit_link_for_a_school
    then_should_be_on_the_edit_page_for_the_school
    when_i_edit_the_school_details
    and_i_submit_for(support_provider_school_edit_page)
    then_i_should_see_a_success_message_for(:updated)
    and_the_school_details_are_updated
  end

  scenario 'i cannot update with invalid data' do
    and_i_click_on_the_edit_link_for_a_school
    and_i_submit_with_invalid_data
    then_i_should_see_a_an_error_message
  end

  scenario "i can delete a provider's school" do
    and_i_click_on_the_edit_link_for_a_school
    and_i_choose_to_delete_the_school
    then_the_school_should_be_deleted
  end

  def when_i_visit_a_provider_schools_page
    support_provider_schools_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def then_i_should_see_a_list_of_schools
    expect(support_provider_schools_index_page.schools.size).to eq(1)

    expect(support_provider_schools_index_page.schools.first.name).to have_text(site.location_name)
    expect(support_provider_schools_index_page.schools.first.code).to have_text(site.code)
    expect(support_provider_schools_index_page.schools.first.urn).to have_text(site.urn)
  end

  def and_i_click_on_the_add_school_link
    support_provider_schools_index_page.add_school.click
  end

  def then_should_be_on_the_create_page_for_the_school
    expect(support_provider_school_create_page).to be_displayed
  end

  def when_i_add_the_school_details
    support_provider_school_create_page.school_form.location_name.set('Acre woods')
    support_provider_school_create_page.school_form.urn.set('12345')
    support_provider_school_create_page.school_form.building_and_street.set('100 Acre Woods')
    support_provider_school_create_page.school_form.town_or_city.set('London')
    support_provider_school_create_page.school_form.postcode.set('BN1 1AA')
  end

  def and_the_new_school_should_show_in_the_list
    expect(support_provider_schools_index_page.schools.first.name).to have_text('Acre woods')
  end

  def and_i_click_on_the_edit_link_for_a_school
    support_provider_schools_index_page.schools.first.edit_link.click
  end

  def then_should_be_on_the_edit_page_for_the_school
    expect(support_provider_school_edit_page).to be_displayed
  end

  def when_i_edit_the_school_details
    support_provider_school_edit_page.school_form.location_name.set('Updated school name')
  end

  def and_i_submit_for(page_object)
    page_object.submit.click
  end

  def then_i_should_see_a_success_message_for(flash_key)
    expect(page).to have_content(I18n.t("support.flash.#{flash_key}", resource: 'School'))
  end

  def and_the_school_details_are_updated
    site.reload

    expect(site.location_name).to eq('Updated school name')
  end

  def and_i_submit_with_invalid_data
    support_provider_school_edit_page.school_form.location_name.set(nil)
    and_i_submit_for(support_provider_school_edit_page)
  end

  def then_i_should_see_a_an_error_message
    expect(support_provider_school_edit_page.errors.size).to eq(1)
  end

  def and_i_choose_to_delete_the_school
    support_provider_school_edit_page.delete_record.click
  end

  def then_the_school_should_be_deleted
    expect(support_provider_schools_index_page.schools.size).to eq(0)
  end

  def provider
    @provider ||= create(:provider, sites: [build(:site)])
  end

  def site
    @site ||= provider.sites.first
  end
end
