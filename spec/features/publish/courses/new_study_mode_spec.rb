require "rails_helper"

feature "selecting full time or part time or full or part time" do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_new_study_mode_page
  end

  scenario "selecting full time" do
    when_i_select_a_study_mode(:full_time)
    and_i_click_continue
    then_i_am_met_with_the_locations_page(:full_time)
  end

  scenario "selecting part time" do
    when_i_select_a_study_mode(:part_time)
    and_i_click_continue
    then_i_am_met_with_the_locations_page(:part_time)
  end

  scenario "selecting full or part time" do
    when_i_select_a_study_mode(:full_time_or_part_time)
    and_i_click_continue
    then_i_am_met_with_the_locations_page(:full_time_or_part_time)
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

  def when_i_visit_the_new_study_mode_page
    new_study_mode_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: study_mode_params)
  end

  def when_i_select_a_study_mode(study_mode)
    new_study_mode_page.study_mode_fields.send(study_mode).click
  end

  def and_i_click_continue
    new_study_mode_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_locations_page(study_mode)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/locations/new#{selected_params(study_mode)}")
    expect(page).to have_content("Select the locations for this course")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Pick full time, part time or full time and part time")
  end

  def selected_params(study_mode)
    "?course%5Bage_range_in_years%5D=%5B%223_to_7%22%5D&course%5Bis_send%5D=%5B%220%22%5D&course%5Blevel%5D=primary&course%5Bstudy_mode%5D=#{study_mode}&course%5Bsubjects_ids%5D%5B%5D=2"
  end
end
