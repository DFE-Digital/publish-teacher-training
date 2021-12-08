# frozen_string_literal: true

require "rails_helper"

feature "View provider users" do
  let(:user) { create(:user, :admin) }

  scenario "i can view users belong to a provider" do
    given_i_am_authenticated(user: user)
    and_there_is_a_provider
    when_i_visit_the_provider_show_page
    and_click_on_the_users_tab
    then_i_should_see_a_table_of_users
  end

  def and_there_is_a_provider
    @provider = create(:provider, :with_users)
  end

  def when_i_visit_the_provider_show_page
    provider_show_page.load(id: @provider.id)
  end

  def and_click_on_the_users_tab
    provider_show_page.users_tab.click
  end

  def then_i_should_see_a_table_of_users
    expect(provider_users_index_page.users.size).to eq(4)
  end
end
