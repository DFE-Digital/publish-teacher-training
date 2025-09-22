# frozen_string_literal: true

require "rails_helper"

RSpec.describe "View users" do
  let(:user) { create(:user, :admin) }

  scenario "i can view users" do
    given_i_am_authenticated(user:)
    when_i_visit_the_support_users_index_page
    then_i_should_see_a_table_of_users
    when_i_click_the_name
    then_it_takes_me_to_the_users_page
  end

  def and_there_is_a_provider
    @provider = create(:provider)
  end

  def when_i_visit_the_support_users_index_page
    support_users_index_page.load(recruitment_cycle_year: Find::CycleTimetable.cycle_year_from_time(Time.zone.now))
  end

  def and_click_on_the_users_tab
    support_users_index_page.users_tab.click
  end

  def then_i_should_see_a_table_of_users
    expect(support_users_index_page.users.size).to eq(1)
    expect(support_users_index_page.users.first.full_name.text).to eq(user.full_name)
  end

  def when_i_click_the_name
    support_users_index_page.users.first.full_name.click
  end

  def then_it_takes_me_to_the_users_page
    expect(support_user_show_page).to be_displayed
  end
end
