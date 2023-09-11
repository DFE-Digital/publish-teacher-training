# frozen_string_literal: true

require 'rails_helper'

feature 'Edit school under provider as an admin', :with_publish_constraint, { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_provider_site
  end

  describe 'Updating school' do
    scenario 'With valid details' do
      given_i_visit_the_support_provider_schools_index_page
      and_i_click_the_edit_link
      then_i_am_on_the_schools_show_page
      and_i_click_change_name
      then_i_am_on_the_schools_edit_page
      and_i_change_school_details
      and_i_click_update
      then_i_am_on_the_schools_show_page
      and_the_school_is_updated
      and_i_click_back
      then_i_am_on_the_index_page
    end

    scenario 'With invalid details' do
      and_i_visit_the_support_provider_school_edit_page
      and_i_set_invalid_details
      and_i_click_update
      then_i_see_an_error_message
      and_the_school_is_not_updated
    end
  end

  def then_i_am_on_the_index_page
    expect(support_provider_schools_index_page).to be_displayed
  end

  def and_i_click_back
    click_link 'Back'
  end

  def and_the_school_is_not_updated
    @site.reload
    expect(@site.location_name).to include 'Main Site'
  end

  def then_i_see_an_error_message
    expect(support_provider_school_edit_page.error_summary).to have_text('Enter a name')
  end

  def and_i_set_invalid_details
    support_provider_school_edit_page
      .school_form
      .location_name
      .set('')
  end

  def and_i_visit_the_support_provider_school_edit_page
    support_provider_school_edit_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: @provider.id, id: @site.id)
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
    support_provider_school_edit_page
      .school_form
      .location_name
      .set('Test name')
  end

  def then_i_am_on_the_schools_edit_page
    expect(support_provider_school_edit_page).to be_displayed
  end

  def and_i_click_change_name
    support_provider_school_show_page.change_name.click
  end

  def then_i_am_on_the_schools_show_page
    expect(support_provider_school_show_page).to be_displayed
  end

  def and_i_click_the_edit_link
    support_provider_schools_index_page.schools.first.edit_link.click
  end

  def given_i_visit_the_support_provider_schools_index_page
    support_provider_schools_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: @provider.id)
  end

  def and_there_is_a_provider_site
    @provider = create(:provider, provider_name: 'School of Cats')
    @site = create(:site, provider: @provider)
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end
end
