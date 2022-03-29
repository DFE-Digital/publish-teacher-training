require "rails_helper"

feature "selecting a subject" do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_secondary_course_i_want_to_edit
  end

  scenario "selecting language" do
    when_i_visit_the_edit_course_modern_languages_page
    when_i_select_a_language
    and_i_click_continue
    then_i_am_met_with_course_details_page
    and_i_should_see_a_success_message
  end

  scenario "redirect due to lacking modern languages id in query" do
    when_i_visit_the_edit_course_modern_languages_page(with_invalid_query: true)
    then_i_am_redirected_to_course_details_page
  end

  scenario "invalid entries" do
    when_i_visit_the_edit_course_modern_languages_page
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def and_there_is_a_secondary_course_i_want_to_edit
    given_a_course_exists(:secondary)
  end

  def given_i_am_authenticated_as_a_provider_user
    provider = create(:provider)
    @user = create(:user, providers: [provider])
    given_i_am_authenticated(user: @user)
  end

  def and_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.saved"))
  end

  def modern_languages_subject
    @modern_languages ||= find(:secondary_subject, :modern_languages)
  end

  def when_i_select_a_language
    modern_languages_edit_page.language_checkbox(language_subject.subject_name).click
  end

  def edit_course_modern_languages_page_with_query(invalid: false)
    params = {}
    params = {}.merge("course[subjects_ids][]": modern_languages_subject.id) unless invalid

    params
  end

  def when_i_visit_the_edit_course_modern_languages_page(with_invalid_query: false)
    query = edit_course_modern_languages_page_with_query(invalid: with_invalid_query)
    modern_languages_edit_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, course_code: course.course_code, query: query)
  end

  def and_i_click_continue
    modern_languages_edit_page.continue.click
  end

  def language
    @language ||= %i[
      french english_as_a_second_language_or_other_language german
      italian japanese mandarin russian spanish modern_languages_other
    ].sample
  end

  def language_subject
    @language_subject ||= find(:modern_languages_subject, language)
  end

  def provider
    @provider ||= @user.providers.first
  end

  def course
    @course ||= provider.courses.first
  end

  def then_i_am_met_with_course_details_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/details")
  end

  def then_i_am_redirected_to_course_details_page
    then_i_am_met_with_course_details_page
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select at least one language")
  end

  def selected_params(with_subjects: false)
    params = ""
    params += "?course%5Bsubjects_ids%5D%5B%5D=#{modern_languages_subject.id}" unless with_subjects

    params
  end
end
