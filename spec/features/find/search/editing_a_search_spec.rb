require "rails_helper"

feature "Editing a search" do
  scenario "Candidate edits their search" do
    when_i_execute_a_valid_search
    then_i_should_see_the_results_page

    when_i_change_my_search_query
    then_i_should_see_the_start_page
    and_the_across_england_radio_button_should_be_selected

    when_i_click_continue
    then_i_should_see_the_age_groups_form
    and_the_primary_radio_button_should_be_selected

    when_i_click_continue
    then_i_should_see_the_subjects_form
    and_the_primary_checkbox_should_be_selected
  end

  def when_i_execute_a_valid_search
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    and_i_select_the_primary_radio_button
    and_i_click_continue
    and_i_select_the_primary_subject_checkbox
    and_i_click_find_courses
  end

private

  def when_i_visit_the_start_page
    courses_by_location_or_training_provider_page.load
  end

  def and_i_select_the_across_england_radio_button
    courses_by_location_or_training_provider_page.across_england.choose
  end

  def and_i_click_continue
    courses_by_location_or_training_provider_page.continue.click
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def and_age_group_radio_selected
    expect(find_field("Primary")).to be_checked
  end

  def and_i_select_the_primary_radio_button
    age_groups_page.primary.choose
  end

  def and_i_click_find_courses
    primary_subjects_page.find_courses.click
  end

  def and_i_select_the_primary_subject_checkbox
    primary_subjects_page.primary.check
  end

  def then_i_should_see_the_results_page
    expect(results_page).to be_displayed
    expect(results_page.current_url).to end_with("/results?age_group=primary&has_vacancies=true&l=2&subjects%5B%5D=00")
  end

  def when_i_change_my_search_query
    click_link "Change"
  end

  def then_i_should_see_the_start_page
    expect(courses_by_location_or_training_provider_page).to be_displayed
  end

  def and_the_across_england_radio_button_should_be_selected
    expect(courses_by_location_or_training_provider_page.across_england).to be_checked
  end

  def and_the_primary_radio_button_should_be_selected
    expect(age_groups_page.primary).to be_checked
  end

  def then_i_should_see_the_subjects_form
    expect(primary_subjects_page.current_url).to end_with(
      "/subjects?age_group=primary&has_vacancies=true&l=2&qualification%5B%5D=qts&qualification%5B%5D=pgce_with_qts&qualification%5B%5D=pgce+pgde&send_courses=false&study_type%5B%5D=full_time&study_type%5B%5D=part_time&subjects%5B%5D=00"
    )
  end

  def and_the_primary_checkbox_should_be_selected
    expect(primary_subjects_page.primary).to be_checked
  end

  def then_i_should_see_the_age_groups_form
    expect(age_groups_page).to be_displayed
  end
end
