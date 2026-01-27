# frozen_string_literal: true

require "rails_helper"

RSpec.describe "A levels back navigation", travel: mid_cycle, type: :system do
  scenario "back navigation preserves selections" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_tda_course

    when_i_visit_the_what_a_level_is_required_page
    then_the_back_link_points_to_description_tab

    when_i_add_a_subject_and_continue
    then_i_am_on_the_add_to_list_page

    when_i_choose_not_to_add_another
    and_i_click_continue
    then_i_am_on_the_consider_pending_a_level_page

    when_i_choose_yes_for_pending_a_levels
    and_i_click_continue
    then_i_am_on_the_equivalencies_page

    when_i_click_back
    then_i_am_on_the_consider_pending_a_level_page
    and_the_yes_option_is_selected_for_pending

    when_i_choose_no_for_pending_a_levels
    and_i_click_continue
    then_i_am_on_the_equivalencies_page

    when_i_click_back
    then_i_am_on_the_consider_pending_a_level_page
    and_the_no_option_is_selected_for_pending
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

  def when_i_visit_the_what_a_level_is_required_page
    visit publish_provider_recruitment_cycle_course_a_levels_what_a_level_is_required_path(
      @provider.provider_code,
      recruitment_cycle_year,
      @course.course_code,
    )
  end

  def then_the_back_link_points_to_description_tab
    expect(page.find_link(text: "Back")[:href]).to match(
      publish_provider_recruitment_cycle_course_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
      ),
    )
  end

  def when_i_add_a_subject_and_continue
    choose "Any subject"
    fill_in "Minimum grade required (optional)", with: "C"
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

  def when_i_choose_not_to_add_another
    choose "No"
  end

  def and_i_click_continue
    click_on "Continue"
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

  def when_i_choose_yes_for_pending_a_levels
    choose "Yes"
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

  def when_i_click_back
    click_on "Back"
  end

  def and_the_yes_option_is_selected_for_pending
    expect(page).to have_checked_field("consider-pending-a-level-pending-a-level-yes-field", visible: :all)
  end

  def when_i_choose_no_for_pending_a_levels
    choose "No"
  end

  def and_the_no_option_is_selected_for_pending
    expect(page).to have_checked_field("consider-pending-a-level-pending-a-level-no-field", visible: :all)
  end

  def recruitment_cycle_year
    RecruitmentCycle.current.year
  end
end
