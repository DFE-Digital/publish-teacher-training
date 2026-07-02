# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing school experience requirements", travel: mid_cycle, type: :system do
  scenario "provider says school experience is required and adds details" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_salaried_course

    when_i_visit_the_course_description_tab
    then_i_see_the_school_experience_row

    when_i_click_to_change_school_experience
    then_i_am_on_the_experience_required_page

    when_i_choose_that_experience_is_required
    and_i_click_continue
    then_i_am_on_the_experience_details_page

    when_i_enter_the_experience_details
    and_i_click_update
    then_i_am_back_on_the_course_description_tab
    and_i_see_the_success_message
    and_i_see_the_school_experience_requirements
  end

  scenario "provider says school experience is not required" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_salaried_course

    when_i_visit_the_course_description_tab
    when_i_click_to_change_school_experience
    then_i_am_on_the_experience_required_page

    when_i_choose_that_experience_is_not_required
    and_i_click_continue
    then_i_am_back_on_the_course_description_tab
    and_i_see_the_success_message
    and_i_see_that_experience_is_not_required
  end

  scenario "provider chooses yes then cancels on the details step without leaving orphaned data" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_salaried_course

    when_i_visit_the_course_description_tab
    when_i_click_to_change_school_experience
    then_i_am_on_the_experience_required_page

    when_i_choose_that_experience_is_required
    and_i_click_continue
    then_i_am_on_the_experience_details_page

    when_i_cancel
    then_i_am_back_on_the_course_description_tab
    and_the_course_has_no_school_experience_recorded
  end

  scenario "provider submits the experience required step without choosing an option" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_salaried_course

    when_i_visit_the_course_description_tab
    when_i_click_to_change_school_experience
    then_i_am_on_the_experience_required_page

    and_i_click_continue
    then_i_am_back_on_the_course_description_tab
    and_the_course_has_no_school_experience_recorded
  end

  scenario "provider sees the previous cycle's school experience content on the details step" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_salaried_course
    and_the_course_had_school_experience_content_in_the_previous_cycle

    when_i_visit_the_course_description_tab
    when_i_click_to_change_school_experience
    then_i_am_on_the_experience_required_page

    when_i_choose_that_experience_is_required
    and_i_click_continue
    then_i_am_on_the_experience_details_page
    and_i_can_see_the_previous_cycles_school_experience_content
  end

  scenario "provider sees no recap when there was no school experience content last cycle" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_salaried_course

    when_i_visit_the_course_description_tab
    when_i_click_to_change_school_experience
    then_i_am_on_the_experience_required_page

    when_i_choose_that_experience_is_required
    and_i_click_continue
    then_i_am_on_the_experience_details_page
    and_i_do_not_see_the_last_cycle_recap
  end

private

  def given_i_am_authenticated_as_a_provider_user
    # School experience is only shown for courses in the 2027 cycle or later.
    @user = create(:user, providers: [build(:provider, recruitment_cycle: create(:recruitment_cycle, :next))])
    @provider = @user.providers.first
    given_i_am_authenticated(user: @user)
  end

  def and_i_have_a_salaried_course
    @course = create(:course, :with_salary, provider: @provider)
  end

  def and_the_course_had_school_experience_content_in_the_previous_cycle
    previous_provider = create(:provider, provider_code: @provider.provider_code, recruitment_cycle: create(:recruitment_cycle))
    create(
      :course,
      course_code: @course.course_code,
      provider: previous_provider,
      school_experience_required: true,
      school_experience_required_content: "Spend a week observing lessons in a UK school.",
    )
  end

  def when_i_visit_the_course_description_tab
    visit publish_provider_recruitment_cycle_course_path(
      @provider.provider_code,
      @provider.recruitment_cycle_year,
      @course.course_code,
    )
  end

  def then_i_see_the_school_experience_row
    expect(page).to have_content("School experience (optional)")
  end

  def when_i_click_to_change_school_experience
    click_link "Change", href: experience_required_path
  end

  def then_i_am_on_the_experience_required_page
    expect(page).to have_current_path(experience_required_path, ignore_query: true)
    expect(page).to have_content("Is school experience required or strongly recommended for this course?")
  end

  def when_i_choose_that_experience_is_required
    choose "Yes, school experience is required or strongly recommended"
  end

  def when_i_choose_that_experience_is_not_required
    choose "No, school experience is not required"
  end

  def and_i_click_continue
    click_on "Continue to add school experience details"
  end

  def then_i_am_on_the_experience_details_page
    expect(page).to have_current_path(experience_details_path, ignore_query: true)
    expect(page).to have_content("What school experience are you looking for?")
  end

  def when_i_enter_the_experience_details
    fill_in "What school experience are you looking for?", with: "Spend two weeks in a UK school."
  end

  def and_i_click_update
    click_on "Update school experience"
  end

  def then_i_am_back_on_the_course_description_tab
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_path(
        @provider.provider_code,
        @provider.recruitment_cycle_year,
        @course.course_code,
      ),
      ignore_query: true,
    )
  end

  def and_i_see_the_success_message
    expect(page).to have_content("School experience updated")
  end

  def and_i_see_the_school_experience_requirements
    expect(@course.reload.school_experience_required).to be(true)
    expect(@course.school_experience_required_content).to eq("Spend two weeks in a UK school.")
    expect(page).to have_content("Spend two weeks in a UK school.")
  end

  def and_i_see_that_experience_is_not_required
    expect(@course.reload.school_experience_required).to be(false)
    expect(page).to have_content("No, school experience is not required")
  end

  def and_i_can_see_the_previous_cycles_school_experience_content
    expect(page).to have_content("See what you wrote last cycle")
    page.find("span", text: "See what you wrote last cycle").click

    expect(page).to have_content("Spend a week observing lessons in a UK school.")
  end

  def and_i_do_not_see_the_last_cycle_recap
    expect(page).to have_no_content("See what you wrote last cycle")
  end

  def when_i_cancel
    click_on "Cancel"
  end

  def and_the_course_has_no_school_experience_recorded
    expect(@course.reload.school_experience_required).to be_nil
    expect(@course.school_experience_required_content).to be_nil
  end

  def experience_required_path
    publish_provider_recruitment_cycle_course_school_experience_required_path(
      @provider.provider_code,
      @provider.recruitment_cycle_year,
      @course.course_code,
    )
  end

  def experience_details_path
    publish_provider_recruitment_cycle_course_school_experience_details_path(
      @provider.provider_code,
      @provider.recruitment_cycle_year,
      @course.course_code,
    )
  end
end
