# frozen_string_literal: true

require 'rails_helper'

feature 'Delete school under provider as an admin', :with_publish_constraint, { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_provider_site
    and_i_visit_the_support_provider_school_show_page
  end

  describe 'Deleting a school' do
    scenario do
      when_i_click_remove_school_link
      then_i_am_on_the_school_delete_page
      when_i_click_cancel
      then_i_am_on_the_school_show_page

      when_i_click_remove_school_link
      and_i_click_remove_school_button
      then_i_am_on_the_index_page
      and_the_school_is_deleted
    end
  end

  def and_the_school_is_deleted
    expect(@provider.sites.count).to eq 0
  end

  def then_i_am_on_the_index_page
    expect(support_provider_schools_index_page).to be_displayed
    expect(page).to have_text 'School successfully deleted'
  end

  def and_i_click_remove_school_button
    click_link_or_button 'Remove school'
  end

  def then_i_am_on_the_school_show_page
    expect(support_provider_school_show_page).to be_displayed
  end

  def when_i_click_cancel
    click_link_or_button 'Cancel'
  end

  def then_i_am_on_the_school_delete_page
    expect(support_provider_school_delete_page).to be_displayed
  end

  def when_i_click_remove_school_link
    click_link_or_button 'Remove school'
  end

  def and_i_visit_the_support_provider_school_show_page
    support_provider_school_show_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: @provider.id, id: @site.id)
  end

  def and_there_is_a_provider_site
    @provider = create(:provider, provider_name: 'School of Cats')
    @site = create(:site, provider: @provider)
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end
end
