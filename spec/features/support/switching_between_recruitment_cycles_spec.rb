require "rails_helper"

feature "Support index" do
  scenario "viewing support cycles page during rollover" do
    given_we_are_in_rollover
    and_there_are_two_recruitment_cycles
    and_i_am_authenticated_as_an_admin_user
    when_i_visit_the_support_index_page
    then_i_should_be_on_the_recruitment_cycle_switcher_page
    and_should_not_see_the_switch_cycle_link

    when_i_click_on_the_current_cycle
    i_should_see_the_current_cycle_page
    and_i_should_see_the_pe_allocations_tab # This method can be deleted after rollover 2022

    when_click_the_switch_cycle_link
    and_click_on_the_next_cycle
    i_should_be_on_the_next_cycle_page
    and_i_should_not_see_the_pe_allocations_tab # This method can be deleted after rollover 2022
  end

  scenario "viewing providers page when not in rollover" do
    given_we_are_not_in_rollover
    and_there_are_two_recruitment_cycles
    and_i_am_authenticated_as_an_admin_user
    when_i_visit_the_support_index_page
    then_i_should_be_on_the_support_providers_page
  end

  def then_i_should_be_on_the_support_providers_page
    expect(support_provider_index_page).to be_displayed
  end

  def given_we_are_in_rollover
    allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(true)
  end

  def given_we_are_not_in_rollover
    allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(false)
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
    expect(support_provider_index_page).not_to have_link "Change recruitment cycle"
  end

  def when_i_click_on_the_current_cycle
    click_link "#{Settings.current_recruitment_cycle_year} - current"
  end

  def and_click_on_the_next_cycle
    click_link Settings.current_recruitment_cycle_year + 1
  end

  def i_should_see_the_current_cycle_page
    expect(support_provider_index_page).to have_text "Recruitment cycle #{Settings.current_recruitment_cycle_year - 1} to #{Settings.current_recruitment_cycle_year} - current"
  end

  def when_click_the_switch_cycle_link
    click_link "Change recruitment cycle"
  end

  def i_should_be_on_the_next_cycle_page
    expect(support_provider_index_page).to have_text "Recruitment cycle #{Settings.current_recruitment_cycle_year} to #{Settings.current_recruitment_cycle_year + 1}"
  end

  def and_i_should_see_the_pe_allocations_tab
    expect(support_provider_index_page).to have_link "PE Allocations"
  end

  def and_i_should_not_see_the_pe_allocations_tab
    expect(support_provider_index_page).not_to have_link "PE Allocations"
  end
end
