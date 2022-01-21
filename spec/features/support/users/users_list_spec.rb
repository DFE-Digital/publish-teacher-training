# frozen_string_literal: true

require "rails_helper"

feature "View users" do
  let(:user) { create(:user, :admin) }

  scenario "i can view users" do
    given_i_am_authenticated(user: user)
    when_i_visit_the_users_index_page
    then_i_should_see_a_table_of_users
    when_i_click_the_name
    then_it_takes_me_to_the_users_page
  end

  def and_there_is_a_provider
    @provider = create(:provider)
  end

  def when_i_visit_the_users_index_page
    users_index_page.load
  end

  def and_click_on_the_users_tab
    users_index_page.users_tab.click
  end

  def then_i_should_see_a_table_of_users
    expect(users_index_page.users.size).to eq(1)
    expect(users_index_page.users.first.full_name.text).to eq(user.full_name)
  end

  def when_i_click_the_name
    users_index_page.users.first.full_name.click
  end

  def then_it_takes_me_to_the_users_page
    expect(users_show_page).to be_displayed
  end
end
