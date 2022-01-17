# frozen_string_literal: true

require "rails_helper"

feature "Viewing a user" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_there_is_a_user
    when_i_visit_the_provider_show_page
    and_click_on_the_users_tab
    i_can_see_a_list_of_users
    and_i_click_on_the_user
  end

  scenario "i can view providers that belong to a user" do
    then_i_should_see_a_table_of_providers
  end

  def when_i_visit_the_provider_show_page
    provider_show_page.load(id: @user.providers.first.id)
  end

  def and_there_is_a_user
    @user = create(:user, :with_provider)
  end

  def and_click_on_the_users_tab
    provider_show_page.users_tab.click
  end

  def i_can_see_a_list_of_users
    expect(provider_users_index_page.users.first.full_name.text).to eq(@user.full_name)
  end

  def and_i_click_on_the_user
    provider_users_index_page.users.first.full_name.click
  end

  def then_i_should_see_a_table_of_providers
    expect(users_show_page.provider_rows.size).to eq(1)
  end
end
