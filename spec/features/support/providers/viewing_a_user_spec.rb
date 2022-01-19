# frozen_string_literal: true

require "rails_helper"

feature "Viewing a user" do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user, :with_provider) }

  before do
    given_i_am_authenticated(user: admin)
    when_i_visit_the_provider_show_page
    and_click_on_the_users_tab
    and_i_click_on_the_user
  end

  scenario "i am directed to the user show page" do
    then_i_am_directed_to_the_user_show_page
  end

  def when_i_visit_the_provider_show_page
    provider_show_page.load(id: user.providers.first.id)
  end

  def and_click_on_the_users_tab
    provider_show_page.users_tab.click
  end

  def and_i_click_on_the_user
    provider_users_index_page.users.first.email.click
  end

  def then_i_am_directed_to_the_user_show_page
    expect(users_show_page).to be_displayed
  end
end
