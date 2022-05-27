require "rails_helper"

feature "Providers index" do
  scenario "view page as Mary - multi provider user" do
    given_the_new_publish_flow_feature_flag_is_enabled
    and_i_am_authenticated_as_a_multi_provider_user
    when_i_visit_the_publish_providers_index_page
    i_should_see_the_provider_list
    i_should_not_see_the_admin_search_box

    and_i_click_on_a_provider
    i_should_see_the_change_organisation_link
    when_i_click_the_change_organisation_link
    i_should_see_the_provider_list
  end

  scenario "view page as Colin - admin user" do
    given_the_new_publish_flow_feature_flag_is_enabled
    and_i_am_authenticated_as_an_admin_user
    and_there_are_providers
    when_i_visit_the_publish_providers_index_page
    i_should_see_the_provider_list
    i_should_see_the_admin_search_box
    i_should_see_the_pagination_link
    i_can_search_with_provider_details

    i_should_not_see_the_change_organisation_link
  end

  def given_the_new_publish_flow_feature_flag_is_enabled
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
    publish_providers_index_page.search_input.set "Really big school (A01)"
    publish_providers_index_page.search_button.click
    expect(publish_provider_courses_index_page).to be_displayed
    expect(publish_provider_courses_index_page.current_url).to end_with("A01/2022/courses")
  end

  def i_should_see_the_pagination_link
    expect(publish_providers_index_page.pagination_pages.text).to eq("2 of 3")
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
    create_list(:provider, 20)
  end

  def and_i_click_on_a_provider
    click_link "Bat School"
  end

  def i_should_see_the_change_organisation_link
    expect(page).to have_text "Change organisation"
  end

  def when_i_click_the_change_organisation_link
    click_link "Change organisation"
  end

  def i_should_not_see_the_change_organisation_link
    expect(page).not_to have_text "Change organisation"
  end

  def given_the_new_publish_flow_feature_flag_is_enabled
    allow(Settings.features).to receive(:new_publish_navigation).and_return(true)
  end
end
