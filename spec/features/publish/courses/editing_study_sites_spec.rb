# frozen_string_literal: true

require 'rails_helper'

feature 'updating study sites on a course', { can_edit_current_and_next_cycles: false } do
  before do
    given_the_study_sites_feature_flag_is_active
  end

  scenario 'provider has no study sites' do
    and_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_course_details_page
    then_i_see_the_add_a_study_site_link
  end

  scenario 'user can add and remove study sites from a course' do
    when_i_am_authenticated_as_a_provider_user_in_the_next_cycle_with_study_sites
    and_visit_the_course_details_page
    and_i_click_add_study_site
    and_the_study_site_checkbox_is_not_checked
    and_i_check_the_first_study_site_and_submit
    then_i_should_see_the_study_site_location_name

    given_i_click_change_study_sites
    and_the_previously_selected_study_site_is_still_checked
    and_i_uncheck_the_first_study_site_and_submit
    then_i_see_the_success_message
  end

  def then_i_see_the_success_message
    expect(page).to have_text('Study sites updated')
  end

  def then_i_see_the_add_a_study_site_link
    expect(page).to have_link('Add a study site')
  end

  def then_i_see_the_error_message_add_one_study_site
    expect(page).to have_link('Add at least one study site')
  end

  def given_the_study_sites_feature_flag_is_active
    allow(Settings.features).to receive(:study_sites).and_return(true)
  end

  def and_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, :next_recruitment_cycle, sites: [build(:site)], courses: [build(:course)])
        ]
      )
    )
  end

  def provider
    @current_user.providers.first
  end

  def when_i_visit_the_publish_course_study_sites_edit_page
    visit study_sites_publish_provider_recruitment_cycle_course_path(
      provider_code: provider.provider_code, code: @course.course_code, recruitment_cycle_year: provider.recruitment_cycle_year
    )
  end

  def when_i_visit_the_course_details_page
    publish_provider_courses_details_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code
    )
  end

  def when_i_am_authenticated_as_a_provider_user_in_the_next_cycle_with_study_sites
    providers = [build(:provider, :next_recruitment_cycle, sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site)], courses: [build(:course, :with_accrediting_provider, applications_open_from: '2023-10-10', start_date: '2023-10-10')])]
    @user = create(:user, providers:)
    given_i_am_authenticated(user: @user)
  end

  def and_visit_the_course_details_page
    publish_provider_courses_details_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code
    )
  end

  def course
    provider.courses.first
  end

  def and_i_click_add_study_site
    click_link 'Select a study site'
  end

  def and_i_check_the_first_study_site_and_submit
    check(provider.study_sites.first.location_name)
    click_button 'Update study sites'
  end

  def and_i_uncheck_the_first_study_site_and_submit
    uncheck(provider.study_sites.first.location_name)
    click_button 'Update study sites'
  end

  def then_i_should_see_the_study_site_location_name
    expect(page).to have_text(provider.study_sites.first.location_name)
  end

  def given_i_click_change_study_sites
    click_link 'Change study sites'
  end

  def and_the_previously_selected_study_site_is_still_checked
    expect(page).to have_field(checked: true)
  end

  def and_the_study_site_checkbox_is_not_checked
    expect(page).not_to have_field(checked: true)
  end

  def given_i_click_cancel
    click_link 'Cancel'
  end

  def given_i_publish_the_course
    click_button 'Publish course'
  end

  def when_i_click_add_at_lease_one_study_site
    click_link 'Add at least one study site'
  end

  def then_i_should_be_on_the_study_sites_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{course.recruitment_cycle_year}/study-sites")
  end

  alias_method :and_there_is_a_course_i_want_to_edit, :given_a_course_exists
end
