# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support index" do
  after { travel_back }

  scenario "viewing support cycles page during rollover", travel: find_closes do
    given_we_have_a_next_cycle
    and_there_are_two_recruitment_cycles
    and_today_is_before_next_cycle_available_for_support_users_date
    and_i_am_authenticated_as_an_admin_user
    when_i_visit_the_support_index_page
    then_i_should_be_on_the_support_providers_page

    and_today_is_after_next_cycle_available_for_support_users_date
    and_i_am_authenticated_as_an_admin_user
    when_i_visit_the_support_index_page
    then_i_should_be_on_the_recruitment_cycle_switcher_page
    and_should_not_see_the_switch_cycle_link

    when_i_click_on_the_current_cycle
    i_should_see_the_current_cycle_page

    when_click_the_switch_cycle_link
    and_click_on_the_next_cycle
    i_should_be_on_the_next_cycle_page
  end

  scenario "viewing providers page when not in rollover", travel: mid_cycle do
    given_we_have_a_next_cycle
    and_there_are_two_recruitment_cycles
    and_i_am_authenticated_as_an_admin_user
    when_i_visit_the_support_index_page
    then_i_should_be_on_the_support_providers_page
  end

  def then_i_should_be_on_the_support_providers_page
    expect(support_provider_index_page).to be_displayed
  end

  def given_we_have_a_next_cycle
    create(
      :recruitment_cycle,
      :next,
      available_in_publish_from: 1.week.from_now,
      available_for_support_users_from: 1.day.from_now,
    )
  end

  def and_there_are_two_recruitment_cycles
    find_or_create(:recruitment_cycle, :previous)
    find_or_create(:recruitment_cycle, :next)
  end

  def and_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def when_i_visit_the_support_index_page
    support_recruitment_cycle_index_page.load
  end

  def then_i_should_be_on_the_recruitment_cycle_switcher_page
    expect(support_recruitment_cycle_index_page).to have_link "#{Settings.current_recruitment_cycle_year} - current"
    expect(support_recruitment_cycle_index_page).to have_link Settings.current_recruitment_cycle_year + 1
  end

  def and_should_not_see_the_switch_cycle_link
    expect(support_provider_index_page).to have_no_link "Change recruitment cycle"
  end

  def when_i_click_on_the_current_cycle
    click_link_or_button "#{RecruitmentCycle.current.year} - current"
  end

  def and_click_on_the_next_cycle
    click_link_or_button RecruitmentCycle.next.year
  end

  def i_should_see_the_current_cycle_page
    expect(support_provider_index_page).to have_text "Recruitment cycle #{Settings.current_recruitment_cycle_year - 1} to #{Settings.current_recruitment_cycle_year} - current"
  end

  def when_click_the_switch_cycle_link
    click_link_or_button "Change recruitment cycle"
  end

  def i_should_be_on_the_next_cycle_page
    expect(support_provider_index_page).to have_text "Recruitment cycle #{Settings.current_recruitment_cycle_year} to #{Settings.current_recruitment_cycle_year + 1}"
  end

  def and_i_should_see_the_pe_allocations_tab
    expect(support_provider_index_page).to have_link "PE Allocations"
  end

  def and_i_should_not_see_the_pe_allocations_tab
    expect(support_provider_index_page).to have_no_link "PE Allocations"
  end

  def and_today_is_before_next_cycle_available_for_support_users_date
    travel_to(RecruitmentCycle.next.available_for_support_users_from - 1.day)
  end

  def and_today_is_after_next_cycle_available_for_support_users_date
    travel_to(RecruitmentCycle.next.available_for_support_users_from + 1.day)
  end
end
