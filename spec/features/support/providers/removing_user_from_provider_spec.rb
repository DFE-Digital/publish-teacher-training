# frozen_string_literal: true

require "rails_helper"

feature "Removing a user from provider" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_a_user_provider_relationship_exists_to_remove
    and_i_visit_the_support_provider_user_show_page
    and_i_click_the_remove_user_link
    and_i_am_taken_to_the_support_provider_user_delete_page
  end

  scenario "Removing a user-provider relationship" do
    when_i_click_remove_user_button
    then_i_am_redirected_to_support_provider_users_index_page
    and_a_success_message_is_displayed
    and_the_user_provider_relationship_is_destroyed
  end

private

  def and_a_user_provider_relationship_exists_to_remove
    @provider = create(:provider)
    @user = create(:user, providers: [@provider])
  end

  def and_i_visit_the_support_provider_user_show_page
    support_provider_user_show_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, id: @user.id, provider_id: @provider.id)
  end

  def and_i_click_the_remove_user_link
    support_provider_user_show_page.remove_user_link.click
  end

  def and_i_am_taken_to_the_support_provider_user_delete_page
    expect(support_provider_user_delete_page).to be_displayed
    expect(support_provider_user_delete_page.heading).to have_content("#{@user.full_name} - #{@provider.provider_name}")
    expect(support_provider_user_delete_page.warning_text).to have_content("The user will be sent an email to tell them you removed them from #{@provider.provider_name}.")
    expect(support_provider_user_delete_page.cancel_link["href"]).to eq(support_recruitment_cycle_provider_user_path(@provider.recruitment_cycle_year, @provider, @user))
  end

  def when_i_click_remove_user_button
    support_provider_user_delete_page.remove_user_button.click
  end

  def then_i_am_redirected_to_support_provider_users_index_page
    expect(support_provider_users_index_page).to be_displayed
  end

  def and_a_success_message_is_displayed
    expect(support_provider_users_index_page.success_notification).to have_content("User removed")
  end

  def and_the_user_provider_relationship_is_destroyed
    @provider.reload
    expect(@provider.users).to be_empty
    expect(support_provider_users_index_page.users).to be_empty
  end
end
