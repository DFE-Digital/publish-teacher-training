# frozen_string_literal: true

require "rails_helper"

feature "Editing a user under a provider as an admin" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_a_user_provider_relationship_exists_to_edit
    and_i_visit_the_support_provider_user_show_page
  end

  scenario "Editing a user from a provider" do
    when_i_click_the_change_firstname_link
    and_i_am_taken_to_the_support_provider_user_edit_page
    and_i_fill_the_form
    and_i_click_update
    then_should_see_the_updated_details_displayed

    when_i_click_the_change_lastname_link
    and_i_fill_the_form
    and_i_click_update
    then_should_see_the_updated_details_displayed

    when_i_click_the_change_email_link
    and_i_fill_the_form
    and_i_click_update
    then_should_see_the_updated_details_displayed
  end

private

  def and_a_user_provider_relationship_exists_to_edit
    @provider = create(:provider)
    @user = create(:user, providers: [@provider])
  end

  def and_i_visit_the_support_provider_user_show_page
    support_provider_user_show_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, id: @user.id, provider_id: @provider.id)
  end

  def when_i_click_the_change_firstname_link
    support_provider_user_show_page.change_first_name.click
  end

  def and_i_fill_the_form
    support_provider_user_edit_page.first_name.set("Aba")
    support_provider_user_edit_page.last_name.set("Bernharb")
    support_provider_user_edit_page.email.set("viela_fisher@boyle.io")
  end

  def and_i_click_update
    support_provider_user_edit_page.update_user.click
  end

  def then_should_see_the_updated_details_displayed
    expect(support_users_check_page).to have_text("Aba")
    expect(support_users_check_page).to have_text("Bernharb")
    expect(support_users_check_page).to have_text("viela_fisher@boyle.io")
  end

  def when_i_click_the_change_lastname_link
    support_provider_user_show_page.change_last_name.click
  end

  def when_i_click_the_change_email_link
    support_provider_user_show_page.change_email.click
  end

  def and_i_am_taken_to_the_support_provider_user_edit_page
    expect(support_provider_user_edit_page).to be_displayed
  end

  def then_i_am_redirected_to_support_provider_users_index_page
    expect(support_provider_user_edit_page).to be_displayed
  end
end
