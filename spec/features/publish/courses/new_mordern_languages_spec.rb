require "rails_helper"

feature "selecting a subject" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "selecting language" do
    when_i_visit_the_new_course_modern_languages_page(with_invalid_query: false)
    when_i_select_a_language
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(with_invalid_params: false)
  end

  scenario "redirect due to lacking modern languages id in query" do
    when_i_visit_the_new_course_modern_languages_page(with_invalid_query: true)
    then_i_am_redirected_to_age_range_page
  end

  scenario "invalid entries" do
    when_i_visit_the_new_course_modern_languages_page
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def modern_languages_subject
    @modern_languages ||= find(:secondary_subject, :modern_languages)
  end

  def when_i_select_a_language
    new_modern_languages_page.language_checkbox(language_subject.subject_name).click
  end

  def new_course_modern_languages_page_with_query(invalid: false)
    params = secondary_subject_params
    params = secondary_subject_params.merge("course[subjects_ids][]": modern_languages_subject.id) unless invalid

    params
  end

  def when_i_visit_the_new_course_modern_languages_page(with_invalid_query: false)
    query = new_course_modern_languages_page_with_query(invalid: with_invalid_query)
    new_modern_languages_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: query)
  end

  def and_i_click_continue
    new_modern_languages_page.continue.click
  end

  def language
    @language ||= %i[french english_as_a_second_language_or_other_language german italian japanese mandarin russian spanish modern_languages_other].sample
  end

  def language_subject
    @language_subject ||= find(:modern_languages_subject, language)
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_redirected_to_age_range_page
    then_i_am_met_with_the_age_range_page(with_invalid_params: true)
  end

  def then_i_am_met_with_the_age_range_page(with_invalid_params: false)
    params = selected_params(with_subjects: with_invalid_params)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/age-range/new#{params}")
    expect(page).to have_content("Specify an age range")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select at least one language")
  end

  def selected_params(with_subjects: false)
    params = "?course%5Bis_send%5D=%5B%220%22%5D&course%5Blevel%5D=secondary"
    params += "&course%5Bsubjects_ids%5D%5B%5D=#{modern_languages_subject.id}" unless with_subjects
    params += "&course%5Bsubjects_ids%5D%5B%5D=#{language_subject.id}" unless with_subjects
    params
  end
end
