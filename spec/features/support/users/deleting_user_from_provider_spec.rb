# frozen_string_literal: true

require "rails_helper"

feature "Deleting a provider from user" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_a_user_provider_relationship_exists_to_remove
    when_i_visit_the_user_show_page
  end

  scenario "Deleting a user-provider relationship" do
    when_i_click_the_remove_user_from_provider_button
    then_i_am_taken_to_the_user_index_page
    with_a_success_message
    and_the_user_provider_relationship_is_destroyed
  end

private

  def and_a_user_provider_relationship_exists_to_remove
    @provider = create(:provider)
    @user = create(:user, providers: [@provider])
  end

  def when_i_visit_the_user_show_page
    users_show_page.load(id: @user.id)
  end

  def when_i_click_the_remove_user_from_provider_button
    users_show_page.remove_user_from_provider_button.click
  end

  def then_i_am_taken_to_the_user_index_page
    expect(users_show_page).to be_displayed
  end

  def with_a_success_message
    expect(users_show_page).to have_content("#{@user.first_name} #{@user.last_name} removed from #{@provider.provider_name}")
  end

  def and_the_user_provider_relationship_is_destroyed
    @user.reload
    expect(@user.providers.length).to eq 0
    expect(users_show_page.provider_rows.length).to eq 0
  end
end
