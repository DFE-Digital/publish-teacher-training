# frozen_string_literal: true

require "rails_helper"

feature "View users" do
  let(:user) { create(:user, :admin) }

  scenario "i can view users" do
    given_i_am_authenticated(user: user)
    when_i_visit_the_users_index_page
    then_i_should_see_a_table_of_users
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
  end
end
