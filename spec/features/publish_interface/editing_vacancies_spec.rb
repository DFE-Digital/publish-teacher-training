# frozen_string_literal: true

require "rails_helper"

feature "Editing vacancies" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  context "a full time course with one running site" do
    scenario "presents a checkbox to turn off all vacancies" do
      and_there_is_a_full_time_course_with_one_running_site
      when_i_visit_the_vacancy_edit_page_for_a_course
      then_i_should_see_a_checkbox_to_turn_off_all_vacancies
      when_i_check_the_checkbox_to_turn_off_all_vacancies
      and_i_submit
      then_the_vacancies_are_turned_off
    end

    scenario "shows an error if the form is submitted without confirming" do
      and_there_is_a_full_time_course_with_one_running_site
      when_i_visit_the_vacancy_edit_page_for_a_course
      and_i_submit_with_invalid_data
      then_i_should_see_a_an_error_message
    end
  end

  context "a full time or part time course with one running site but no vacancies" do
    scenario "full time course presents a checkbox to turn on all vacancies" do
      and_there_is_a_full_time_course_with_one_site_and_no_vacancies
      when_i_visit_the_vacancy_edit_page_for_a_course
      then_i_should_see_a_checkbox_to_turn_on_all_vacancies
      when_i_check_the_checkbox_to_turn_on_all_vacancies
      and_i_submit
      then_the_vacancies_are_turned_on("full_time_vacancies")
    end

    scenario "part time course presents a checkbox to turn on all vacancies" do
      and_there_is_a_part_time_course_with_one_site_and_no_vacancies
      when_i_visit_the_vacancy_edit_page_for_a_course
      then_i_should_see_a_checkbox_to_turn_on_all_vacancies
      when_i_check_the_checkbox_to_turn_on_all_vacancies
      and_i_submit
      then_the_vacancies_are_turned_on("part_time_vacancies")
    end

    scenario "shows an error if the form is submitted without confirming" do
      and_there_is_a_full_time_course_with_one_site_and_no_vacancies
      when_i_visit_the_vacancy_edit_page_for_a_course
      and_i_submit_with_invalid_data
      then_i_should_see_a_an_error_message
    end
  end

  scenario "a full time course with multiple running sites only render site statuses that are running" do
    and_there_is_a_full_time_course_with_multiple_sites
    when_i_visit_the_vacancy_edit_page_for_a_course
    then_i_should_see_a_checkbox_for_each_running_site
  end

  scenario "a full time course with multiple running sites but no vacancies shows course as having no vacancies" do
    and_there_is_a_full_time_course_with_sites_and_no_vacancies
    when_i_visit_the_vacancy_edit_page_for_a_course
    then_i_should_see_the_course_as_having_no_vacancies
  end

  scenario "a full time or part time course with one site presents a radio button choice and shows both study modes for the site" do
    and_there_is_a_full_or_part_time_course_with_one_full_and_part_time_site
    when_i_visit_the_vacancy_edit_page_for_a_course
    then_i_should_see_a_checkbox_for_each_study_mode
  end

  scenario "a full time or part time course with multiple running sites shows both study modes for each site" do
    and_there_is_a_full_or_part_time_course_with_multiple_sites
    when_i_visit_the_vacancy_edit_page_for_a_course
    then_i_should_see_a_checkbox_for_each_study_mode_per_site
  end

  context "removing vacancies for a course" do
    scenario "removing a full time vacancy with no vacancies remaining" do
      and_there_is_a_full_time_course_with_multiple_sites
      when_i_visit_the_vacancy_edit_page_for_a_course
      and_i_uncheck_the_sites
      and_i_submit
      then_the_vacancies_are_turned_off
    end

    scenario "removing all vacancies" do
      and_there_is_a_full_time_course_with_multiple_sites
      when_i_visit_the_vacancy_edit_page_for_a_course
      and_i_choose_to_remove_all_vacancies
      and_i_submit
      then_the_vacancies_are_turned_off
    end

    scenario "removing a full time vacancy with one remaining" do
      and_there_is_a_full_time_course_with_multiple_sites
      when_i_visit_the_vacancy_edit_page_for_a_course
      and_i_uncheck_some_sites
      and_i_submit
      then_the_vacancies_are_updated_with(%w[no_vacancies full_time_vacancies])
    end
  end

  context "adding vacancies for a course" do
    scenario "all locations have vacancies" do
      and_there_is_a_full_time_course_with_sites_and_no_vacancies
      when_i_visit_the_vacancy_edit_page_for_a_course
      and_i_check_all_the_sites
      and_i_submit
      then_the_vacancies_are_turned_on("full_time_vacancies")
    end

    scenario "some locations have vacancies" do
      and_there_is_a_full_time_course_with_sites_and_no_vacancies
      when_i_visit_the_vacancy_edit_page_for_a_course
      and_i_check_some_sites
      and_i_submit
      then_the_vacancies_are_updated_with(%w[full_time_vacancies no_vacancies])
    end
  end

  scenario "adding a part time vacancy for a course thats full or part time" do
    and_there_is_a_full_or_part_time_course_with_one_full_time_site
    when_i_visit_the_vacancy_edit_page_for_a_course
    and_i_check_the_part_time_site
    and_i_submit
    then_the_vacancies_are_updated_with(%w[both_full_time_and_part_time_vacancies])
  end

private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_full_time_course_with_one_running_site
    given_a_course_exists
    given_a_site_exists(:full_time_vacancies, :findable)
  end

  def and_there_is_a_full_time_course_with_one_site_and_no_vacancies
    given_a_course_exists
    given_a_site_exists(:no_vacancies, :findable)
  end

  def and_there_is_a_part_time_course_with_one_site_and_no_vacancies
    given_a_course_exists(:part_time)
    given_a_site_exists(:no_vacancies, :findable)
  end

  def and_there_is_a_full_time_course_with_multiple_sites
    given_a_course_exists
    given_a_site_exists(:full_time_vacancies, :findable, site: build(:site, location_name: "Site 1"))
    given_a_site_exists(:full_time_vacancies, :findable, site: build(:site, location_name: "Site 2"))
  end

  def and_there_is_a_full_time_course_with_sites_and_no_vacancies
    given_a_course_exists
    given_a_site_exists(:no_vacancies, :findable, site: build(:site, location_name: "Site 1"))
    given_a_site_exists(:no_vacancies, :findable, site: build(:site, location_name: "Site 2"))
  end

  def and_there_is_a_full_or_part_time_course_with_one_full_and_part_time_site
    given_a_course_exists(:full_time_or_part_time)
    given_a_site_exists(
      :both_full_time_and_part_time_vacancies,
      :findable,
      site: build(:site, location_name: "Uni full and part time 1"),
    )
  end

  def and_there_is_a_full_or_part_time_course_with_one_full_time_site
    given_a_course_exists(:full_time_or_part_time)
    given_a_site_exists(
      :full_time_vacancies,
      :findable,
      site: build(:site, location_name: "Uni 1"),
    )
  end

  def and_there_is_a_full_or_part_time_course_with_multiple_sites
    given_a_course_exists(:full_time_or_part_time)
    given_a_site_exists(:full_time_vacancies, :findable, site: build(:site, location_name: "Uni 1"))
    given_a_site_exists(:part_time_vacancies, :findable, site: build(:site, location_name: "Uni 2"))
    given_a_site_exists(:both_full_time_and_part_time_vacancies, :findable, site: build(:site, location_name: "Uni 3"))
    given_a_site_exists(:full_time_vacancies, :suspended, site: build(:site, location_name: "Not running Uni"))
  end

  def given_a_site_exists(*traits, **overrides)
    course.site_statuses << build(:site_status, *traits, **overrides)
  end

  def when_i_visit_the_vacancy_edit_page_for_a_course
    publish_provider_vacancies_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_submit_with_invalid_data
    publish_provider_vacancies_edit_page.submit.click
  end

  def then_i_should_see_a_an_error_message
    expect(publish_provider_vacancies_edit_page.error_messages).to include(vacancies_confirmation_error_message)
  end

  def then_i_should_see_a_checkbox_to_turn_off_all_vacancies
    expect(publish_provider_vacancies_edit_page).to have_content("I confirm there are no vacancies")
    expect(publish_provider_vacancies_edit_page).to have_content("Close this course")
    expect(publish_provider_vacancies_edit_page).to have_confirm_no_vacancies
    expect(publish_provider_vacancies_edit_page.confirm_no_vacancies).not_to be_checked
  end

  def then_i_should_see_a_checkbox_to_turn_on_all_vacancies
    expect(publish_provider_vacancies_edit_page).to have_content("I confirm there are vacancies")
    expect(publish_provider_vacancies_edit_page).to have_content("Reopen this course")
    expect(publish_provider_vacancies_edit_page).to have_confirm_has_vacancies
    expect(publish_provider_vacancies_edit_page.confirm_has_vacancies).not_to be_checked
  end

  def then_i_should_see_a_checkbox_for_each_running_site
    expect(publish_provider_vacancies_edit_page).to have_vacancies_radio_choice
    expect(publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies).to be_checked
    expect(publish_provider_vacancies_edit_page.vacancy_names).to match_array(["Site 1", "Site 2"])
  end

  def then_i_should_see_the_course_as_having_no_vacancies
    expect(publish_provider_vacancies_edit_page).to have_vacancies_radio_choice
    expect(publish_provider_vacancies_edit_page.vacancies_radio_no_vacancies).to be_checked
    expect(publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies).not_to be_checked
    expect(publish_provider_vacancies_edit_page.vacancy_checked_values).to all(be_falsey)
  end

  def then_i_should_see_a_checkbox_for_each_study_mode
    expect(publish_provider_vacancies_edit_page).to have_vacancies_radio_choice
    expect(publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies).to be_checked
    expect(publish_provider_vacancies_edit_page.vacancy_names).to match_array(
      ["Uni full and part time 1 (Full time)", "Uni full and part time 1 (Part time)"],
    )
    expect(publish_provider_vacancies_edit_page.vacancy_checked_values).to all(be_truthy)
  end

  def then_i_should_see_a_checkbox_for_each_study_mode_per_site
    expected_checkbox_state = {
      "Uni 1 (Full time)" => true,
      "Uni 1 (Part time)" => false,
      "Uni 2 (Full time)" => false,
      "Uni 2 (Part time)" => true,
      "Uni 3 (Full time)" => true,
      "Uni 3 (Part time)" => true,
    }

    expect(publish_provider_vacancies_edit_page).to have_vacancies_radio_choice
    expect(publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies).to be_checked
    expect(publish_provider_vacancies_edit_page.vacancy_names).to match_array(expected_checkbox_state.keys)
    expect(publish_provider_vacancies_edit_page.vacancy_checked_values).to match_array(expected_checkbox_state.values)
  end

  def when_i_check_the_checkbox_to_turn_off_all_vacancies
    publish_provider_vacancies_edit_page.confirm_no_vacancies.check
  end

  def when_i_check_the_checkbox_to_turn_on_all_vacancies
    publish_provider_vacancies_edit_page.confirm_has_vacancies.check
  end

  def and_i_uncheck_the_sites
    expect(publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies).to be_checked
    expect(publish_provider_vacancies_edit_page.vacancy_names).to match_array(["Site 1", "Site 2"])

    publish_provider_vacancies_edit_page.vacancies.each(&:uncheck)
  end

  def and_i_check_all_the_sites
    expect(publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies).not_to be_checked

    publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies.choose
    publish_provider_vacancies_edit_page.vacancies.each(&:check)
  end

  def and_i_uncheck_some_sites
    expect(publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies).to be_checked

    publish_provider_vacancies_edit_page.vacancies.find { |el| el.text == "Site 1" }.uncheck
  end

  def and_i_check_some_sites
    expect(publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies).not_to be_checked
    publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies.choose

    publish_provider_vacancies_edit_page.vacancies.find { |el| el.text == "Site 1" }.check
  end

  def and_i_check_the_part_time_site
    expect(publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies).to be_checked

    publish_provider_vacancies_edit_page.vacancies.find { |el| el.text == "Uni 1 (Part time)" }.check
  end

  def and_i_choose_to_remove_all_vacancies
    expect(publish_provider_vacancies_edit_page.vacancies_radio_has_some_vacancies).to be_checked
    expect(publish_provider_vacancies_edit_page.vacancy_names).to match_array(["Site 1", "Site 2"])

    publish_provider_vacancies_edit_page.vacancies_radio_no_vacancies.choose
  end

  def and_i_submit
    publish_provider_vacancies_edit_page.submit.click
  end

  def then_the_vacancies_are_turned_off
    expect(course.site_statuses.pluck(:vac_status)).to all(eq("no_vacancies"))
  end

  def then_the_vacancies_are_turned_on(status)
    expect(course.site_statuses.pluck(:vac_status)).to all(eq(status))
  end

  def then_the_vacancies_are_updated_with(expected_array)
    expect(course.site_statuses.pluck(:vac_status)).to match_array(expected_array)
  end

  def provider
    @current_user.providers.first
  end

  def vacancies_confirmation_error_message
    if course.has_vacancies?
      "Please confirm there are no vacancies to close applications"
    else
      "Please confirm there are vacancies to reopen applications"
    end
  end
end
