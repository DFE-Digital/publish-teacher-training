# frozen_string_literal: true

require "rails_helper"

RSpec.describe "View provider users" do
  let(:user) { create(:user, :admin) }

  scenario "i can view users belong to a provider" do
    given_i_am_authenticated(user:)
    and_there_is_a_provider
    when_i_visit_the_support_provider_show_page
    and_click_on_the_users_tab
    then_i_should_see_a_table_of_users
    and_i_see_the_month_and_year_they_last_signed_in
    and_i_see_that_a_user_who_never_signed_in_says_so
  end

  scenario "i can remove a user from the list" do
    given_i_am_authenticated(user:)
    and_there_is_a_provider
    when_i_visit_the_support_provider_show_page
    and_click_on_the_users_tab
    and_i_click_remove_user_for_the_user_who_has_signed_in
    then_i_am_taken_to_the_support_provider_user_delete_page
  end

  def and_there_is_a_provider
    @provider = create(:provider, :with_users)
    @signed_in_user = create(:user, first_name: "Ada", last_name: "Aardvark", last_login_date_utc: Time.zone.local(2024, 10, 15, 9, 30), providers: [@provider])
    @never_signed_in_user = create(:user, first_name: "Bob", last_name: "Bobson", providers: [@provider])
  end

  def when_i_visit_the_support_provider_show_page
    support_provider_show_page.load(recruitment_cycle_year: Find::CycleTimetable.current_year, id: @provider.id)
  end

  def and_click_on_the_users_tab
    support_provider_show_page.users_tab.click
  end

  def then_i_should_see_a_table_of_users
    expect(support_provider_users_index_page.users.size).to eq(6)
  end

  def and_i_see_the_month_and_year_they_last_signed_in
    expect(page).to have_table(with_rows: [{ "Name" => @signed_in_user.full_name, "Last signed in" => "October 2024" }])
  end

  def and_i_see_that_a_user_who_never_signed_in_says_so
    expect(page).to have_table(with_rows: [{ "Name" => @never_signed_in_user.full_name, "Last signed in" => "Never signed in" }])
  end

  def and_i_click_remove_user_for_the_user_who_has_signed_in
    click_link_or_button "Remove user for #{@signed_in_user.full_name}"
  end

  def then_i_am_taken_to_the_support_provider_user_delete_page
    expect(support_provider_user_delete_page).to be_displayed(
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      provider_id: @provider.id,
      id: @signed_in_user.id,
    )
  end
end
