# frozen_string_literal: true

require "rails_helper"

feature "Deleting a new user" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_a_user_exists_to_delete
    when_i_visit_the_user_show_page(@user_to_delete.id)
  end

  scenario "Deleting a user record" do
    when_i_click_the_delete_button
    then_i_am_taken_to_the_user_index_page
    with_a_success_message
    and_the_user_is_in_a_discarded_state
  end

private

  def and_a_user_exists_to_delete
    @user_to_delete = create(:user)
  end

  def when_i_visit_the_user_show_page(user_id)
    support_users_show_page.load(id: user_id)
  end

  def when_i_click_the_delete_button
    support_users_show_page.delete_button.click
  end

  def then_i_am_taken_to_the_user_index_page
    expect(support_users_index_page).to be_displayed
  end

  def with_a_success_message
    expect(support_users_index_page).to have_content("User successfully deleted")
  end

  def and_the_user_is_in_a_discarded_state
    @user_to_delete.reload
    expect(@user_to_delete.discarded?).to be true
  end
end
