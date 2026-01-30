# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Maximum A level subjects limit", travel: mid_cycle, type: :system do
  scenario "maximum of four A level subjects can be added" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_tda_course

    when_i_visit_the_what_a_level_is_required_page
    and_i_add_the_first_subject
    then_i_am_on_the_add_to_list_page
    and_i_see_the_option_to_add_another

    when_i_add_the_second_subject
    then_i_am_on_the_add_to_list_page
    and_i_see_the_option_to_add_another

    when_i_add_the_third_subject
    then_i_am_on_the_add_to_list_page
    and_i_see_the_option_to_add_another

    when_i_add_the_fourth_subject
    then_i_am_on_the_add_to_list_page
    and_i_see_all_four_subjects
    and_i_do_not_see_the_option_to_add_another
    and_the_back_link_points_to_description_tab

    when_i_click_continue
    then_i_am_on_the_consider_pending_a_level_page

    when_i_choose_no
    and_i_click_continue
    then_i_am_on_the_equivalencies_page

    when_i_choose_no
    and_i_click_update_a_levels
    then_i_am_on_the_course_description_tab
    and_i_see_all_four_subjects_displayed
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

  def and_i_add_the_first_subject
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

  def and_i_see_the_option_to_add_another
    expect(page).to have_css("legend", text: "Do you want to add another A level or equivalent qualification?")
  end

  def when_i_add_the_second_subject
    choose "Yes"
    click_on "Continue"
    choose "Any STEM subject"
    fill_in "Minimum grade required (optional)", with: "B"
    click_on "Continue"
  end

  def when_i_add_the_third_subject
    choose "Yes"
    click_on "Continue"
    choose "Any humanities subject"
    click_on "Continue"
  end

  def when_i_add_the_fourth_subject
    choose "Yes"
    click_on "Continue"
    choose "Choose a subject"
    select "Mathematics", from: "Subjects"
    click_on "Continue"
  end

  def and_i_see_all_four_subjects
    expect(page).to have_content("Any subject - Grade C or above")
    expect(page).to have_content("Any STEM subject - Grade B or above")
    expect(page).to have_content("Any humanities subject")
    expect(page).to have_content("Mathematics")
    expect(@course.reload.a_level_subject_requirements.size).to eq(4)
  end

  def and_i_do_not_see_the_option_to_add_another
    expect(page).to have_no_css("fieldset.govuk-fieldset")
    expect(page).to have_no_css("legend", text: "Do you want to add another A level or equivalent qualification?")
  end

  def and_the_back_link_points_to_description_tab
    expect(page.find_link(text: "Back")[:href]).to match(
      publish_provider_recruitment_cycle_course_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
      ),
    )
  end

  def when_i_click_continue
    click_on "Continue"
  end
  alias_method :and_i_click_continue, :when_i_click_continue

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

  def and_i_see_all_four_subjects_displayed
    expect(page).to have_content("Any subject - Grade C or above or equivalent")
    expect(page).to have_content("Any STEM subject - Grade B or above or equivalent")
    expect(page).to have_content("Any humanities subject")
    expect(page).to have_content("Mathematics")
  end

  def recruitment_cycle_year
    RecruitmentCycle.current.year
  end
end
