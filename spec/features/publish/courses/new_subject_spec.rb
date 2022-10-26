require "rails_helper"

feature "selecting a subject", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "selecting primary subject" do
    when_i_visit_the_new_course_subject_page(:primary)
    when_i_select_a_subject(:primary_with_english)
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(:primary, :primary_with_english)
  end

  scenario "selecting secondary subject" do
    when_i_visit_the_new_course_subject_page(:secondary)
    when_i_select_a_subject(:business_studies)
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(:secondary, :business_studies)
  end

  scenario "selecting secondary subject modern languages" do
    when_i_visit_the_new_course_subject_page(:secondary)
    when_i_select_a_subject(:modern_languages)
    and_i_click_continue
    then_i_am_met_with_the_modern_languages_page
  end

  scenario "invalid entries" do
    when_i_visit_the_new_course_subject_page(%i[primary secondary].sample)
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_new_course_subject_page(level)
    new_subjects_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: level_params(level))
  end

  def when_i_select_a_subject(subject_type)
    new_subjects_page.subjects_fields.select(course_subject(subject_type).subject_name).click
  end

  def and_i_click_continue
    new_subjects_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_age_range_page(level, subject_type)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/age-range/new?#{params_with_subject(level, subject_type)}")
    expect(page).to have_content("Specify an age range")
  end

  def then_i_am_met_with_the_modern_languages_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/modern-languages/new?#{params_with_subject(:secondary, :modern_languages)}")
    expect(page).to have_content("Pick all the languages for this course")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select at least one subject")
  end

  def course_subject(subject_type)
    case subject_type
    when :primary_with_english
      find_or_create(:primary_subject, :primary_with_english)
    when :business_studies
      find_or_create(:secondary_subject, :business_studies)
    when :modern_languages
      find_or_create(:secondary_subject, :modern_languages)
    end
  end

  def params_with_subject(level, subject_type)
    course_subject = course_subject(subject_type)
    "course%5Bcampaign_name%5D=&course%5Bis_send%5D=%5B%220%22%5D&course%5Blevel%5D=#{level}&course%5Bmaster_subject_id%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}"
  end
end
