# frozen_string_literal: true

require "rails_helper"

# To be repurposed for https://trello.com/c/vEnCHLCI/241-add-user-to-org-via-support-removing-provider-users
xfeature "Deleting a user from provider" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_a_user_provider_relationship_exists_to_remove
    when_i_visit_the_support_provider_show_page
    and_click_on_the_users_tab
  end

  scenario "Deleting a user-provider relationship" do
    when_i_click_the_remove_user_from_provider_button
    then_i_am_taken_to_the_support_provider_users_index_page
    with_a_success_message
    and_the_user_provider_relationship_is_destroyed
  end

private

  def and_a_user_provider_relationship_exists_to_remove
    @provider = create(:provider)
    @user = create(:user, providers: [@provider])
  end

  def when_i_visit_the_support_provider_show_page
    support_provider_show_page.load(id: @user.providers.first.id)
  end

  def and_click_on_the_users_tab
    support_provider_show_page.users_tab.click
  end

  def when_i_click_the_remove_user_from_provider_button
    support_provider_users_index_page.remove_user_from_provider_button.click
  end

  def with_a_success_message
    expect(support_provider_users_index_page).to have_content("User permission successfully deleted")
  end

  def then_i_am_taken_to_the_support_provider_users_index_page
    expect(support_provider_users_index_page).to be_displayed
  end

  def and_the_user_provider_relationship_is_destroyed
    @provider.reload
    expect(@provider.users).to be_empty
    expect(support_provider_users_index_page.users).to be_empty
  end
end
