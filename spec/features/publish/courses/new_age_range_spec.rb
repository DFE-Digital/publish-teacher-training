require "rails_helper"

feature "selecting an age range" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "selecting an age range" do
    when_i_visit_the_new_age_range_page
    when_i_select_an_age_range
    and_i_click_continue
    then_i_am_met_with_the_course_outcome_page("3_to_7")
  end

  scenario "creating a custom age range" do
    when_i_visit_the_new_age_range_page
    when_i_select_another_age_range
    and_fill_out_custom_values
    and_i_click_continue
    then_i_am_met_with_the_course_outcome_page("6_to_12")
  end

  scenario "invalid entries" do
    when_i_visit_the_new_age_range_page

    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_new_age_range_page
    new_age_range_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: age_range_params)
  end

  def when_i_select_an_age_range
    new_age_range_page.age_range_fields.three_to_eleven.click
  end

  def when_i_select_another_age_range
    new_age_range_page.age_range_other.click
  end

  def and_fill_out_custom_values
    new_age_range_page.age_range_from_field.set("6")
    new_age_range_page.age_range_to_field.set("12")
  end

  def and_i_click_continue
    new_age_range_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_course_outcome_page(age_range)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/outcome/new#{selected_params(age_range)}")
    expect(page).to have_content("Pick a course outcome")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select an age range")
  end

  def selected_params(age_range)
    "?course%5Bage_range_in_years%5D=#{age_range}&course%5Bis_send%5D=%5B%220%22%5D&course%5Blevel%5D=primary&course%5Bsubjects_ids%5D%5B%5D=2"
  end
end
