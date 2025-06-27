# frozen_string_literal: true

require "rails_helper"

feature "Providers index" do
  after { travel_back }

  scenario "view page as Mary - multi provider user" do
    given_we_are_not_in_rollover
    and_there_is_a_multi_provider_organisation
    and_i_am_authenticated_as_a_multi_provider_user
    when_i_visit_the_publish_providers_index_page
    i_should_see_the_provider_list
    i_should_not_see_the_admin_search_box

    and_i_click_on_a_provider
    and_i_click_the_change_organisation_link
    i_should_see_the_provider_list
  end

  scenario "view page as Colin - admin user" do
    given_we_are_not_in_rollover
    and_i_am_authenticated_as_an_admin_user
    and_there_are_providers
    when_i_visit_the_publish_providers_index_page
    i_should_see_the_provider_list
    i_should_see_the_admin_search_box
    i_should_see_the_pagination_link
    i_should_only_see_10_providers_per_page
    i_can_search_with_provider_details

    i_should_see_the_change_organisation_link
  end

  scenario "view page as Colin - admin user - during rollover" do
    given_we_are_in_rollover
    and_there_are_providers
    and_today_is_before_next_cycle_available_for_support_users_date
    and_i_am_authenticated_as_an_admin_user
    when_i_visit_the_publish_providers_index_page
    i_should_see_the_provider_list

    when_i_visit_support_page
    then_i_am_on_providers_list_page

    and_today_is_after_next_cycle_available_for_support_users_date
    and_i_am_authenticated_as_an_admin_user
    when_i_visit_support_page
    then_i_see_the_recruitment_cycle_list
  end

  scenario "view page as a multi org user during rollover" do
    given_we_are_in_rollover
    and_there_is_a_multi_provider_organisation
    and_there_are_providers
    and_today_is_before_next_cycle_available_for_publish_users_date
    and_i_am_authenticated_as_a_multi_provider_user
    when_i_visit_the_publish_providers_index_page
    i_should_see_the_provider_list
    and_i_click_on_a_provider
    then_the_change_cycle_link_is_not_visible

    and_today_is_after_next_cycle_available_in_publish_from_date
    and_i_am_authenticated_as_a_multi_provider_user
    when_i_visit_the_publish_providers_index_page
    and_i_click_on_a_provider
    i_should_be_on_the_recruitment_cycle_switcher_page

    when_i_click_on_the_current_cycle_link
    and_click_change_recruitment_cycle
    i_should_be_on_the_recruitment_cycle_switcher_page

    when_i_click_on_the_current_cycle_link
    i_should_be_on_the_courses_index_page_in_the_same_recruitment_cycle
    and_i_click_the_change_organisation_link
    and_i_click_on_a_provider
    when_i_click_on_the_current_cycle_link
    i_should_be_on_the_courses_index_page_in_the_same_recruitment_cycle

    # Tests below for a couple of bugs which prevented those pages from knowing about the recruitment cycle

    when_i_click_on_users
    i_should_see_the_recruitment_cycle_text

    when_i_click_on_organisations
    i_should_see_the_recruitment_cycle_text
  end

  def i_should_see_the_recruitment_cycle_text
    expect(publish_title_bar_page.recruitment_cycle_text).to have_text("#{Settings.current_recruitment_cycle_year.to_i - 1} to #{Settings.current_recruitment_cycle_year} - current")
  end

  def and_today_is_before_next_cycle_available_for_support_users_date
    travel_to(RecruitmentCycle.next.available_for_support_users_from - 1.day)
  end

  def and_today_is_after_next_cycle_available_for_support_users_date
    travel_to(RecruitmentCycle.next.available_for_support_users_from + 1.day)
  end

  def and_today_is_before_next_cycle_available_for_publish_users_date
    travel_to(RecruitmentCycle.next.available_in_publish_from - 1.day)
  end

  def and_today_is_after_next_cycle_available_in_publish_from_date
    travel_to(RecruitmentCycle.next.available_in_publish_from + 1.day)
  end

  def when_i_click_on_users
    publish_primary_nav_page.users.click
  end

  def when_i_click_on_organisations
    publish_primary_nav_page.organisation_details.click
  end

  def when_i_click_on_the_current_cycle_link
    click_link_or_button "#{Settings.current_recruitment_cycle_year.to_i - 1} to #{Settings.current_recruitment_cycle_year} - current"
  end

  def i_should_be_on_the_recruitment_cycle_switcher_page
    expect(page).to have_text "Recruitment cycles"
  end

  def i_should_be_on_the_courses_index_page_in_the_same_recruitment_cycle
    expect(page).to have_current_path("/publish/organisations/#{current_user.providers.first.provider_code}/#{Settings.current_recruitment_cycle_year}/courses")
    expect(page).to have_text "Courses"
  end

  def and_click_change_recruitment_cycle
    click_link_or_button "Change recruitment cycle"
  end

  def given_we_are_not_in_rollover
    create(
      :recruitment_cycle,
      :next,
      available_in_publish_from: 1.week.from_now,
      available_for_support_users_from: 1.day.from_now,
    )
  end

  def given_we_are_in_rollover
    create(
      :recruitment_cycle,
      :next,
      available_in_publish_from: 1.week.from_now,
      available_for_support_users_from: 1.day.from_now,
    )
  end

  def and_there_is_a_multi_provider_organisation
    current_recruitment_cycle = RecruitmentCycle.current
    @accredited_provider = create(:provider, :accredited_provider, recruitment_cycle: current_recruitment_cycle, provider_name: "Bat School")
    @accredited_provider1 = create(:provider, :accredited_provider, recruitment_cycle: current_recruitment_cycle)
    @organisation = create(:organisation, providers: [@accredited_provider, @accredited_provider1])
  end

  def and_i_am_authenticated_as_a_multi_provider_user
    given_i_am_authenticated(user: create(:user, providers: [@accredited_provider, @accredited_provider1], organisations: [@organisation]))
  end

  def and_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def i_can_search_with_provider_details
    publish_providers_index_page.search_input.set "Really big school (A01)"
    publish_providers_index_page.search_button.click
    expect(publish_provider_courses_index_page).to be_displayed
    expect(publish_provider_courses_index_page.current_url).to end_with("A01/#{Settings.current_recruitment_cycle_year}/courses")
  end

  def i_should_see_the_pagination_link
    expect(publish_providers_index_page.pagination_pages.text).to eq("2 of 4")
  end

  def i_should_only_see_10_providers_per_page
    expect(page).to have_css("ul.govuk-list.govuk-list--spaced", count: 10)
  end

  def when_i_visit_the_publish_providers_index_page
    publish_providers_index_page.load
  end

  def i_should_see_the_provider_list
    expect(publish_providers_index_page).to have_provider_list
  end

  def i_should_see_the_admin_search_box
    expect(publish_providers_index_page).to have_admin_search_box
  end

  def i_should_not_see_the_admin_search_box
    expect(publish_providers_index_page).not_to have_admin_search_box
  end

  def and_there_are_providers
    create(:provider, provider_name: "Really big school", provider_code: "A01", courses: [build(:course, course_code: "2VVZ")])
    create(:provider, provider_name: "Slightly smaller school", provider_code: "A02", courses: [build(:course, course_code: "2VVZ")])
    create_list(:provider, 30)
  end

  def and_i_click_on_a_provider
    click_link_or_button "Bat School"
  end

  def i_should_see_the_change_organisation_link
    expect(page).to have_text "Change organisation"
  end

  def i_should_be_on_the_organisations_list
    expect(page).to have_current_path("/?recruitment_cycle_year=#{Settings.current_recruitment_cycle_year}")
    expect(page).to have_text "Organisations"
  end

  def and_i_click_the_change_organisation_link
    click_link_or_button "Change organisation"
  end

  def then_the_change_cycle_link_is_not_visible
    expect(page).not_to have_content("Change recruitment cycle")
  end

  def when_i_visit_support_page
    visit support_root_path
  end

  def then_i_am_on_providers_list_page
    expect(page).to have_current_path(support_recruitment_cycle_providers_path(recruitment_cycle_year: RecruitmentCycle.current.year))
  end

  def then_i_see_the_recruitment_cycle_list
    expect(page).to have_text(RecruitmentCycle.current.year_range)
    expect(page).to have_text(RecruitmentCycle.next.year_range)
  end

  def next_recruitment_cycle
    RecruitmentCycle.next
  end
end
