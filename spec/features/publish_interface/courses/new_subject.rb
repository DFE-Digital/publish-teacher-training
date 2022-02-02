require "rails_helper"

feature "selecting a subject" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "selecting primary subject" do
    when_i_visit_the_new_course_subject_page(:primary)
    when_i_select_a_primary_subject
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(:primary)
  end

  scenario "selecting secondary subject" do
    when_i_visit_the_new_course_subject_page(:secondary)
    when_i_select_a_secondary_subject
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(:secondary)
  end

  scenario "invalid entries" do
    when_i_visit_the_new_course_subject_page(%i[primary secondary].sample)
    and_i_select_nothing
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_new_course_subject_page(level)
    new_subjects_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: send("#{level}_subject_params"))
  end

  def primary_subject_params
    { "course[is_send]" => ["0"], "course[level]" => "primary" }
  end

  def secondary_subject_params
    { "course[is_send]" => ["0"], "course[level]" => "secondary" }
  end

  def when_i_select_a_primary_subject
    new_subjects_page.subjects_fields.select("Primary with English").click
  end

  def when_i_select_a_secondary_subject
    new_subjects_page.subjects_fields.select("Ancient Greek").click
  end

  def and_i_select_nothing; end

  def and_i_click_continue
    new_subjects_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_age_range_page(level)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/age-range/new#{send("#{level}_subject_selected_params")}")
    expect(page).to have_content("Specify an age range")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select at least one subject")
  end

  def primary_subject_selected_params
    "?course%5Bis_send%5D=%5B%220%22%5D&course%5Blevel%5D=primary&course%5Bsubjects%5D%5B%5D=2"
  end

  def secondary_subject_selected_params
    "?course%5Bis_send%5D=%5B%220%22%5D&course%5Blevel%5D=secondary&course%5Bsubjects%5D%5B%5D=35"
  end
end
