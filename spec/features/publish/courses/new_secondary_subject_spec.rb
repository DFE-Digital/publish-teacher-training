# frozen_string_literal: true

require "rails_helper"

feature "selecting a subject" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "selecting one subject" do
    when_i_visit_the_new_course_subject_page
    when_i_select_one_subject(:business_studies)
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(:business_studies)
    and_i_click_back
    then_i_am_met_with_populated_dropdowns(:business_studies)
  end

  scenario "selecting two subjects" do
    when_i_visit_the_new_course_subject_page
    when_i_select_two_subjects(:business_studies, :physics)
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(:business_studies, :physics)
    and_i_click_back
    then_i_am_met_with_populated_dropdowns(:business_studies, :physics)
  end

  scenario "selecting secondary subject modern languages" do
    when_i_visit_the_new_course_subject_page
    when_i_select_one_subject(:modern_languages)
    and_i_click_continue
    then_i_am_met_with_the_modern_languages_page
  end

  scenario "selecting subordinate subject but no master" do
    when_i_visit_the_new_course_subject_page
    when_i_select_subordinate_subject(:business_studies)
    and_i_click_continue
    then_i_am_met_with_errors
  end

  scenario "selecting duplicate subject modern languages" do
    when_i_visit_the_new_course_subject_page
    when_i_select_two_subjects(:modern_languages, :modern_languages)
    and_i_click_continue
    expect(page).to have_content("The second subject must be different to the first subject")

    then_i_am_met_with_populated_dropdowns(:modern_languages, :modern_languages)
  end

  scenario "selecting duplicate first and second subject" do
    when_i_visit_the_new_course_subject_page
    when_i_select_two_subjects(:business_studies, :business_studies)
    and_i_click_continue
    expect(page).to have_content("The second subject must be different to the first subject")
    then_i_am_met_with_populated_dropdowns(:business_studies, :business_studies)
  end

  scenario "invalid entries" do
    when_i_visit_the_new_course_subject_page
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_new_course_subject_page
    publish_courses_new_subjects_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Find::CycleTimetable.cycle_year_for_time(Time.zone.now), query: secondary_subject_params)
  end

  def when_i_select_one_subject(subject_type)
    publish_courses_new_subjects_page.master_subject_fields.select(course_subject(subject_type).subject_name).click
  end

  def when_i_select_subordinate_subject(subject_type)
    publish_courses_new_subjects_page.subordinate_subjects_fields.select(course_subject(subject_type).subject_name).click
  end

  def when_i_select_two_subjects(master, subordinate)
    publish_courses_new_subjects_page.master_subject_fields.select(course_subject(master).subject_name).click
    publish_courses_new_subjects_page.subordinate_subjects_fields.select(course_subject(subordinate).subject_name).click
  end

  def and_i_click_back
    publish_courses_new_subjects_page.back.click
  end

  def and_i_click_continue
    publish_courses_new_subjects_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_populated_dropdowns(master, subordinate = nil)
    expect(publish_courses_new_subjects_page.master_subject_fields.find("option[selected]")).to have_content(course_subject(master))
    expect(publish_courses_new_subjects_page.subordinate_subjects_fields.find("option[selected]")).to have_content(course_subject(subordinate)) if subordinate.present?
  end

  def then_i_am_met_with_the_age_range_page(master, subordinate = nil)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Find::CycleTimetable.cycle_year_for_time(Time.zone.now)}/courses/age-range/new?#{params_with_subject(master, subordinate)}")
    expect(page).to have_content("Age range")
  end

  def then_i_am_met_with_the_modern_languages_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Find::CycleTimetable.cycle_year_for_time(Time.zone.now)}/courses/modern-languages/new?#{params_with_subject(:modern_languages)}")
    expect(page).to have_content("Languages")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a subject")
  end

  def course_subject(subject_type)
    case subject_type
    when :business_studies
      find_or_create(:secondary_subject, :business_studies)
    when :physics
      find_or_create(:secondary_subject, :physics)
    when :modern_languages
      find_or_create(:secondary_subject, :modern_languages)
    end
  end

  def params_with_subject(master_subject, subordinate_subject = nil)
    master_subject = course_subject(master_subject)
    subordinate_subject = course_subject(subordinate_subject)
    if subordinate_subject
      [
        "course%5Bcampaign_name%5D=",
        "course%5Bis_send%5D=0",
        "course%5Blevel%5D=secondary",
        "course%5Bmaster_subject_id%5D=#{master_subject.id}",
        "course%5Bsubjects_ids%5D%5B%5D=#{master_subject.id}",
        "course%5Bsubjects_ids%5D%5B%5D=#{subordinate_subject.id}",
        "course%5Bsubordinate_subject_id%5D=#{subordinate_subject.id}",
      ].join("&")
    else
      [
        "course%5Bcampaign_name%5D=",
        "course%5Bis_send%5D=0",
        "course%5Blevel%5D=secondary",
        "course%5Bmaster_subject_id%5D=#{master_subject.id}",
        "course%5Bsubjects_ids%5D%5B%5D=#{master_subject.id}",
        "course%5Bsubordinate_subject_id%5D=",
      ].join("&")
    end
  end
end
