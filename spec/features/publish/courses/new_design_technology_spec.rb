# frozen_string_literal: true

require "rails_helper"

feature "selecting Design and technology specialisms" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "selecting D&T specialisms routes to age range" do
    when_i_visit_the_new_course_design_technology_page
    when_i_select_a_design_technology_specialism
    and_i_click_continue
    then_i_am_met_with_the_age_range_page
  end

  scenario "D&T master with Modern languages subordinate routes to Modern languages" do
    when_i_visit_the_new_course_design_technology_page_with_subordinate(:modern_languages)
    when_i_select_a_design_technology_specialism
    and_i_click_continue
    then_i_am_met_with_the_modern_languages_page
  end

  scenario "invalid entries" do
    when_i_visit_the_new_course_design_technology_page
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def provider
    @provider ||= @user.providers.first
  end

  def design_technology_subject
    @design_technology_subject ||= find(:secondary_subject, :design_and_technology)
  end

  def new_course_design_technology_query_params
    secondary_subject_params.merge(
      'course[subjects_ids][]': design_technology_subject.id,
      'course[master_subject_id]': design_technology_subject.id,
    )
  end

  def new_course_design_technology_with_subordinate_query_params(subordinate_key)
    subordinate = course_subject(subordinate_key)
    Rack::Utils.build_nested_query(
      course: {
        is_send: 0,
        level: "secondary",
        master_subject_id: design_technology_subject.id,
        subordinate_subject_id: subordinate.id,
        subjects_ids: [design_technology_subject.id, subordinate.id],
      },
    )
  end

  def when_i_visit_the_new_course_design_technology_page
    visit "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/design-technology/new?#{new_course_design_technology_query_params.to_query}"
  end

  def when_i_visit_the_new_course_design_technology_page_with_subordinate(subordinate_key)
    visit "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/design-technology/new?#{new_course_design_technology_with_subordinate_query_params(subordinate_key)}"
  end

  def when_i_select_a_design_technology_specialism
    within(".govuk-checkboxes") { check "Engineering" }
  end

  def and_i_click_continue
    click_button "Continue"
  end

  def then_i_am_met_with_the_age_range_page
    expect(page).to have_current_path(
      "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/age-range/new",
      ignore_query: true,
    )
    expect(page).to have_content("Age range")
  end

  def then_i_am_met_with_the_modern_languages_page
    expect(page).to have_current_path(
      "/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/modern-languages/new",
      ignore_query: true,
    )
    expect(page).to have_content("Languages")
  end

  def course_subject(subject_key)
    case subject_key
    when :physics
      find_or_create(:secondary_subject, :physics)
    when :modern_languages
      find_or_create(:secondary_subject, :modern_languages)
    else
      raise "Unknown subject key: #{subject_key}"
    end
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select at least one specialism")
  end
end
