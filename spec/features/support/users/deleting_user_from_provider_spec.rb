# frozen_string_literal: true

require "rails_helper"

feature "Deleting a provider from user" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_a_user_provider_relationship_exists_to_remove
    when_i_visit_the_user_show_providers_page
  end

  scenario "Deleting a user-provider relationship" do
    when_i_click_the_remove_user_from_provider_button
    then_i_am_taken_to_the_user_show_providers_page
    with_a_success_message
    and_the_user_provider_relationship_is_destroyed
  end

private

  def and_a_user_provider_relationship_exists_to_remove
    @provider = create(:provider)
    @user = create(:user, providers: [@provider])
  end

  def when_i_visit_the_user_show_providers_page
    support_user_show_providers_page.load(id: @user.id)
  end

  def when_i_click_the_remove_user_from_provider_button
    support_user_show_providers_page.remove_user_from_provider_button.click
  end

  def then_i_am_taken_to_the_user_show_providers_page
    expect(support_user_show_providers_page).to be_displayed
  end

  def with_a_success_message
    expect(support_user_show_providers_page).to have_content("User permission successfully deleted")
  end

  def and_the_user_provider_relationship_is_destroyed
    @user.reload
    expect(@user.providers).to be_empty
    expect(support_user_show_providers_page.provider_rows).to be_empty
  end

  def and_i_click_on_the_providers_tab
    support_user_show_providers_page.providers_tab.click
  end
end
