# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support index" do
  scenario "viewing support cycles page during rollover", travel: find_closes do
    given_we_have_a_next_cycle
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

  scenario "viewing providers page when not in rollover" do
    given_we_have_a_next_cycle
    and_today_is_before_next_cycle_available_for_support_users_date
    and_i_am_authenticated_as_an_admin_user
    when_i_visit_the_support_index_page
    then_i_should_be_on_the_support_providers_page
  end

  def then_i_should_be_on_the_support_providers_page
    expect(page).to have_current_path "/support/#{RecruitmentCycle.current.year}/providers", ignore_query: true
  end

  def given_we_have_a_next_cycle
    find_or_create(:recruitment_cycle, :next)
  end

  def and_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def when_i_visit_the_support_index_page
    support_recruitment_cycle_index_page.load
  end

  def then_i_should_be_on_the_recruitment_cycle_switcher_page
    expect(support_recruitment_cycle_index_page).to have_link "#{Find::CycleTimetable.cycle_year_for_time(Time.zone.now)} - current"
    expect(support_recruitment_cycle_index_page).to have_link Find::CycleTimetable.cycle_year_for_time(Time.zone.now) + 1
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
    expect(support_provider_index_page).to have_text "Recruitment cycle #{Find::CycleTimetable.cycle_year_for_time(Time.zone.now) - 1} to #{Find::CycleTimetable.cycle_year_for_time(Time.zone.now)} - current"
  end

  def when_click_the_switch_cycle_link
    click_link_or_button "Change recruitment cycle"
  end

  def i_should_be_on_the_next_cycle_page
    expect(support_provider_index_page).to have_text "Recruitment cycle #{Find::CycleTimetable.cycle_year_for_time(Time.zone.now)} to #{Find::CycleTimetable.cycle_year_for_time(Time.zone.now) + 1}"
  end

  def and_i_should_see_the_pe_allocations_tab
    expect(support_provider_index_page).to have_link "PE Allocations"
  end

  def and_i_should_not_see_the_pe_allocations_tab
    expect(support_provider_index_page).to have_no_link "PE Allocations"
  end

  def and_today_is_before_next_cycle_available_for_support_users_date
    Timecop.travel(1.day.until(RecruitmentCycle.next.available_for_support_users_from))
  end

  def and_today_is_after_next_cycle_available_for_support_users_date
    Timecop.travel(1.day.since(RecruitmentCycle.next.available_for_support_users_from))
  end
end
