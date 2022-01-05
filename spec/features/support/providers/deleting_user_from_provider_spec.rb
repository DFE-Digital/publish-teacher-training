# frozen_string_literal: true

require "rails_helper"

feature "Deleting a user from provider" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_a_user_provider_relationship_exists_to_remove
    when_i_visit_the_provider_show_page
    and_click_on_the_users_tab
  end

  scenario "Deleting a user-provider relationship" do
    when_i_click_the_remove_user_from_provider_button
    then_i_am_taken_to_the_provider_users_index_page
    with_a_success_message
    and_the_user_provider_relationship_is_destroyed
  end

private

  def and_a_user_provider_relationship_exists_to_remove
    @provider = create(:provider)
    @user = create(:user, providers: [@provider])
  end

  def when_i_visit_the_provider_show_page
    provider_show_page.load(id: @user.providers.first.id)
  end

  def and_click_on_the_users_tab
    provider_show_page.users_tab.click
  end

  def when_i_click_the_remove_user_from_provider_button
    provider_users_index_page.remove_user_from_provider_button.click
  end

  def with_a_success_message
    expect(provider_users_index_page).to have_content("#{@user.first_name} #{@user.last_name} removed from #{@provider.provider_name}")
  end

  def then_i_am_taken_to_the_provider_users_index_page
    expect(provider_users_index_page).to be_displayed
  end

  def and_the_user_provider_relationship_is_destroyed
    @provider.reload
    expect(@provider.users.length).to eq 0
    expect(provider_users_index_page.users.length).to eq 0
  end
end
