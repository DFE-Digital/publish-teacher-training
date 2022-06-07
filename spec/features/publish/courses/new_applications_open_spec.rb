require "rails_helper"

feature "choosing an application open from date", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_new_applications_open_from_page
  end

  scenario "selecting as soon as open on Find" do
    when_i_select_as_soon_as_open_on_find
    and_i_click_continue
    then_i_am_met_with_the_start_date_page
  end

  scenario "selecting a custom date" do
    when_i_select_on_a_specific_date
    and_i_put_in_a_custom_date
    and_i_click_continue
    then_i_am_met_with_the_start_date_page
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

  def when_i_visit_the_new_applications_open_from_page
    new_applications_open_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: applications_open_from_params)
  end

  def when_i_select_as_soon_as_open_on_find
    new_applications_open_page.applications_open_field.click
  end

  def when_i_select_on_a_specific_date
    new_applications_open_page.applications_open_field_day.set("1")
    new_applications_open_page.applications_open_field_month.set("1")
    new_applications_open_page.applications_open_field_year.set(Settings.current_recruitment_cycle_year)
    new_applications_open_page.applications_open_field_other.click
  end

  def and_i_put_in_a_custom_date
    new_applications_open_page.applications_open_field_day.click
  end

  def and_i_click_continue
    new_applications_open_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_start_date_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/start-date/new", ignore_query: true)
    expect(page).to have_content("When does the course start?")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select when applications will open and enter the date if applicable")
  end
end
