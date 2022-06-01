require "rails_helper"

feature "selection locations" do
  before do
    given_the_can_edit_current_and_next_cycles_feature_flag_is_disabled
    given_i_am_authenticated_as_a_provider_user
    and_that_sites_exist
    when_i_visit_the_new_locations_page
  end

  scenario "selecting multiple locations" do
    when_i_select_a_location
    and_i_click_continue
    then_i_am_met_with_the_accredited_body_page
  end

  scenario "invalid entries" do
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def and_that_sites_exist
    provider.sites << create_list(:site, 3)
  end

  def when_i_visit_the_new_locations_page
    new_locations_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: locations_params)
  end

  def when_i_select_a_location
    new_locations_page.check(provider.sites.first.location_name)
    new_locations_page.check(provider.sites.second.location_name)
  end

  def and_i_click_continue
    new_locations_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_accredited_body_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/accredited-body/new", ignore_query: true)
    expect(page).to have_content("Who is the accredited body?")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select at least one location for this course")
  end
end
