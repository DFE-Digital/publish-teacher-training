# These tests can be deleted when the `publish_new_navigation` feature flag is removed. All these tests are covered in `provider_index_spec.rb`
require "rails_helper"

feature "Providers index", { can_edit_current_and_next_cycles: false } do
  before do
    given_that_the_new_publish_navigation_feature_flag_is_off
  end

  scenario "view page as Mary - multi provider user" do
    given_i_am_authenticated_as_a_multi_provider_user
    when_i_visit_the_providers_index_page
    i_should_see_the_provider_list
    i_should_not_see_the_admin_search_box
  end

  scenario "view page as Colin - admin user" do
    given_i_am_authenticated_as_an_admin_user
    and_there_are_providers
    when_i_visit_the_providers_index_page
    i_should_see_the_provider_list
    i_should_see_the_admin_search_box
    i_should_see_the_pagination_link
    i_can_search_with_provider_details
  end

  def given_that_the_new_publish_navigation_feature_flag_is_off
    allow(Settings.features).to receive(:new_publish_navigation).and_return(false)
  end

  def given_i_am_authenticated_as_a_multi_provider_user
    current_recruitment_cycle = find_or_create(:recruitment_cycle)
    accredited_body = create(:provider, :accredited_body, recruitment_cycle: current_recruitment_cycle)
    accredited_body1 = create(:provider, :accredited_body, recruitment_cycle: current_recruitment_cycle)
    given_i_am_authenticated(user: create(:user, providers: [accredited_body, accredited_body1]))
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def i_can_search_with_provider_details
    providers_index_page.search_input.set "Really big school (A01)"
    providers_index_page.search_button.click
    expect(publish_providers_show_page).to be_displayed
    expect(publish_providers_show_page.current_url).to end_with("A01")
  end

  def i_should_see_the_pagination_link
    expect(providers_index_page.pagination_pages.text).to eq("2 of 2")
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
    create_list(:provider, 30)
  end
end
