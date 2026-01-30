# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adding A levels to a TDA course", travel: mid_cycle, type: :system do
  scenario "adding A level requirements to a course" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_tda_course

    when_i_visit_the_course_description_tab
    then_i_see_a_levels_row

    when_i_click_to_add_a_level_requirements
    then_i_am_on_the_what_a_level_is_required_page

    when_i_choose_any_subject
    and_i_add_a_minimum_grade_required
    and_i_click_continue
    then_i_am_on_the_add_to_list_page
    and_i_see_the_subject_i_added
    and_i_see_the_success_message

    when_i_choose_to_add_another
    and_i_click_continue
    then_i_am_on_the_what_a_level_is_required_page

    when_i_choose_any_stem_subject
    and_i_add_a_minimum_grade_required
    and_i_click_continue
    then_i_am_on_the_add_to_list_page
    and_i_see_both_subjects

    when_i_choose_not_to_add_another
    and_i_click_continue
    then_i_am_on_the_consider_pending_a_level_page

    when_i_choose_no
    and_i_click_continue
    then_i_am_on_the_equivalencies_page

    when_i_choose_yes
    and_i_add_equivalency_details
    and_i_click_update_a_levels
    then_i_am_on_the_course_description_tab
    and_i_see_the_a_level_requirements_displayed
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, providers: [build(:provider, provider_type: "lead_school")])
    @provider = @user.providers.first
    given_i_am_authenticated(user: @user)
  end

  def and_i_have_a_tda_course
    @course = create(:course, :with_teacher_degree_apprenticeship, provider: @provider)
  end

  def when_i_visit_the_course_description_tab
    publish_provider_courses_show_page.load(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: recruitment_cycle_year,
      course_code: @course.course_code,
    )
  end

  def then_i_see_a_levels_row
    expect(page).to have_content("A levels and equivalency tests")
  end

  def when_i_click_to_add_a_level_requirements
    click_on "Enter A levels and equivalency test requirements"
  end

  def then_i_am_on_the_what_a_level_is_required_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_what_a_level_is_required_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
      ),
      ignore_query: true,
    )
  end

  def when_i_choose_any_subject
    choose "Any subject"
  end

  def and_i_add_a_minimum_grade_required
    fill_in "Minimum grade required (optional)", with: "C"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_on_the_add_to_list_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
      ),
      ignore_query: true,
    )
  end

  def and_i_see_the_subject_i_added
    expect(page).to have_content("Any subject - Grade C or above")
  end

  def and_i_see_the_success_message
    expect(page).to have_content("You have added a required A level or equivalent qualification")
  end

  def when_i_choose_to_add_another
    choose "Yes"
  end

  def when_i_choose_any_stem_subject
    choose "Any STEM subject"
  end

  def and_i_see_both_subjects
    expect(page).to have_content("Any subject - Grade C or above")
    expect(page).to have_content("Any STEM subject - Grade C or above")
  end

  def when_i_choose_not_to_add_another
    choose "No"
  end

  def then_i_am_on_the_consider_pending_a_level_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_consider_pending_a_level_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
      ),
    )
  end

  def when_i_choose_no
    choose "No"
  end

  def then_i_am_on_the_equivalencies_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_a_level_equivalencies_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
      ),
    )
  end

  def when_i_choose_yes
    choose "Yes"
  end

  def and_i_add_equivalency_details
    fill_in "Details about equivalency tests you offer or accept", with: "We accept equivalent qualifications"
  end

  def and_i_click_update_a_levels
    click_on "Update A levels"
  end

  def then_i_am_on_the_course_description_tab
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
      ),
    )
  end

  def and_i_see_the_a_level_requirements_displayed
    expect(page).to have_content("Any subject - Grade C or above or equivalent")
    expect(page).to have_content("Any STEM subject - Grade C or above or equivalent")
    expect(page).to have_content("Candidates with pending A levels will not be considered.")
    expect(page).to have_content("Equivalency tests will be considered.")
    expect(page).to have_content("We accept equivalent qualifications")
  end

  def recruitment_cycle_year
    RecruitmentCycle.current.year
  end
end
