require "rails_helper"

feature "Providers index" do
  scenario "view page as Mary - multi provider user" do
    given_we_are_not_in_rollover
    and_the_new_publish_flow_feature_flag_is_enabled
    and_i_am_authenticated_as_a_multi_provider_user
    when_i_visit_the_providers_index_page
    i_should_see_the_provider_list
    i_should_not_see_the_admin_search_box

    and_i_click_on_a_provider
    and_i_click_the_change_organisation_link
    i_should_see_the_provider_list
  end

  scenario "view page as Colin - admin user" do
    given_we_are_not_in_rollover
    given_the_new_publish_flow_feature_flag_is_enabled
    and_i_am_authenticated_as_an_admin_user
    and_there_are_providers
    when_i_visit_the_providers_index_page
    i_should_see_the_provider_list
    i_should_see_the_admin_search_box
    i_should_see_the_pagination_link
    i_can_search_with_provider_details

    i_should_see_the_change_organisation_link
  end

  scenario "view page as a multi org user during rollover" do
    given_we_are_in_rollover
    and_there_is_a_previous_recruitment_cycle
    and_i_am_authenticated_as_a_multi_provider_user
    and_there_are_providers
    when_i_visit_the_providers_index_page
    and_i_continue_past_the_recruitment_cycle_text
    and_i_click_on_a_provider
    i_should_be_on_the_organisation_switcher_page

    when_i_click_on_the_current_cycle_link
    and_i_click_the_change_organisation_link
    i_should_be_on_the_organisations_list

    and_i_click_on_a_provider
    and_click_change_recruitment_cycle
    i_should_be_on_the_organisation_switcher_page
  end

  def when_i_click_on_the_current_cycle_link
    click_link "2021 to 2022 - current"
  end

  def and_i_continue_past_the_recruitment_cycle_text
    click_button "Continue"
  end

  def and_there_is_a_previous_recruitment_cycle
    find_or_create(:recruitment_cycle, :previous)
  end

  def i_should_be_on_the_organisation_switcher_page
    expect(page).to have_text "Recruitment cycles"
  end

  def and_click_change_recruitment_cycle
    click_link "Change recruitment cycle"
  end

  def given_we_are_not_in_rollover
    allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(false)
  end

  def given_we_are_in_rollover
    allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(true)
  end

  def and_the_new_publish_flow_feature_flag_is_enabled
    enable_features(:new_publish_navigation)
  end

  def and_i_am_authenticated_as_a_multi_provider_user
    current_recruitment_cycle = find_or_create(:recruitment_cycle)
    accredited_body = create(:provider, :accredited_body, recruitment_cycle: current_recruitment_cycle, provider_name: "Bat School")
    accredited_body1 = create(:provider, :accredited_body, recruitment_cycle: current_recruitment_cycle)
    organisation = create(:organisation, providers: [accredited_body, accredited_body1])
    given_i_am_authenticated(user: create(:user, providers: [accredited_body, accredited_body1], organisations: [organisation]))
  end

  def and_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def i_can_search_with_provider_details
    providers_index_page.search_input.set "Really big school (A01)"
    providers_index_page.search_button.click
    expect(provider_courses_index_page).to be_displayed
    expect(provider_courses_index_page.current_url).to end_with("A01/2022/courses")
  end

  def i_should_see_the_pagination_link
    expect(providers_index_page.pagination_pages.text).to eq("2 of 3")
  end

  def when_i_visit_the_providers_index_page
    providers_index_page.load
  end

  def i_should_see_the_provider_list
    expect(providers_index_page).to have_provider_list
  end

  def i_should_see_the_admin_search_box
    expect(providers_index_page).to have_admin_search_box
  end

  def i_should_not_see_the_admin_search_box
    expect(providers_index_page).not_to have_admin_search_box
  end

  def and_there_are_providers
    create(:provider, provider_name: "Really big school", provider_code: "A01", courses: [build(:course, course_code: "2VVZ")])
    create(:provider, provider_name: "Slightly smaller school", provider_code: "A02", courses: [build(:course, course_code: "2VVZ")])
    create_list(:provider, 20)
  end

  def and_i_click_on_a_provider
    click_link "Bat School"
  end

  def i_should_see_the_change_organisation_link
    expect(page).to have_text "Change organisation"
  end

  def i_should_be_on_the_organisations_list
    expect(page).to have_current_path("/")
    expect(page).to have_text "Organisations"
  end

  def and_i_click_the_change_organisation_link
    click_link "Change organisation"
  end

  def given_the_new_publish_flow_feature_flag_is_enabled
    allow(Settings.features).to receive(:new_publish_navigation).and_return(true)
  end
end
