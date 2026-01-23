# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adding A levels subjects to a teacher degree apprenticeship course", travel: mid_cycle, type: :system do
  scenario "adding and removing subjects" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_teacher_degree_apprenticeship_course

    when_i_visit_the_course_description_tab
    then_i_see_a_levels_row

    when_i_click_to_add_a_level_requirements
    then_i_am_on_the_what_a_level_is_required_page
    and_the_back_link_points_to_description_tab

    when_i_click_continue
    then_i_see_an_error_message_for_the_what_a_levels_is_required_for_the_course_page

    when_i_choose_other_subject
    and_i_click_continue
    then_i_see_an_error_message_for_the_what_a_levels_is_required_for_the_course_page

    when_i_choose_any_subject
    and_i_add_a_minimum_grade_required
    and_i_click_continue

    then_i_see_the_subject_i_selected
    and_i_am_on_the_add_another_a_level_subject_page
    and_i_see_the_success_message_that_i_added_an_a_level

    when_i_click_continue
    then_i_see_an_error_message_for_the_add_a_level_to_a_list_page
    and_i_see_the_subject_i_selected

    when_i_choose_yes
    and_i_click_continue
    then_i_am_on_the_what_a_level_is_required_page

    when_i_choose_any_stem_subject
    and_i_add_a_minimum_grade_required
    and_i_click_continue
    then_i_see_the_two_subjects_i_already_added

    when_i_choose_yes
    and_i_click_continue
    then_i_am_on_the_what_a_level_is_required_page
    when_i_choose_any_humanities_subject
    and_i_click_continue
    then_i_see_the_three_subjects_i_already_added

    when_i_choose_yes
    and_i_click_continue
    then_i_am_on_the_what_a_level_is_required_page

    when_i_choose_other_subject
    and_i_select_mathematics
    and_i_click_continue
    then_i_see_the_four_subjects_i_already_added
    and_i_do_not_see_the_option_to_add_more_a_level_subjects
    and_the_back_link_points_to_description_tab

    when_i_click_continue
    then_i_am_on_the_consider_pending_a_level_page
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, providers: [build(:provider, provider_type: "lead_school", sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])])
    @provider = @user.providers.first
    create(:provider, :accredited_provider, provider_code: "1BJ")
    @accredited_provider = create(:provider, :accredited_provider, provider_code: "1BK")

    @provider.accredited_partnerships.create(accredited_provider: @accredited_provider)

    given_i_am_authenticated(user: @user)
  end

  def and_i_have_a_teacher_degree_apprenticeship_course
    @course = create(:course, :with_teacher_degree_apprenticeship, provider: @provider)
  end

  def when_i_visit_the_course_description_tab
    publish_provider_courses_show_page.load(provider_code: @provider.provider_code, recruitment_cycle_year:, course_code: @course.course_code)
  end

  def then_i_see_a_levels_row
    expect(page).to have_content("A levels and equivalency tests")
  end

  def when_i_click_to_add_a_level_requirements
    click_on "Enter A levels and equivalency test requirements"
  end

  def when_i_click_continue
    click_on "Continue"
  end
  alias_method :and_i_click_continue, :when_i_click_continue

  def when_i_choose_no
    choose "No"
  end
  alias_method :and_i_choose_no, :when_i_choose_no

  def then_i_am_on_the_course_description_tab
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
      ),
    )
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

  def and_i_see_a_levels_is_no_required
    expect(page).to have_content("A levels are not required for this course")
  end

  def when_i_choose_yes
    choose "Yes"
  end
  alias_method :and_i_choose_yes, :when_i_choose_yes

  def when_i_click_to_change_a_level_requirements
    click_on "Change A levels"
  end

  def and_the_no_option_is_chosen
    expect(page).to have_checked_field("are-any-a-levels-required-for-this-course-answer-no-field")
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

  def when_i_click_back
    click_on "Back"
  end
  alias_method :and_i_click_back, :when_i_click_back

  def then_the_yes_option_is_chosen
    expect(page).to have_checked_field("are-any-a-levels-required-for-this-course-answer-yes-field")
  end
  alias_method :and_the_yes_option_is_chosen, :then_the_yes_option_is_chosen

  def when_i_choose_other_subject
    choose "Choose a subject"
  end

  def then_i_see_an_error_message_for_the_what_a_levels_is_required_for_the_course_page
    and_i_see_there_is_a_problem
    expect(page).to have_content("Select a subject").twice
  end

  def when_i_choose_any_subject
    choose "Any subject"
  end

  def and_i_add_a_minimum_grade_required
    fill_in "Minimum grade required (optional)", with: "C"
  end

  def then_i_see_the_subject_i_selected
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
      ),
      ignore_query: true,
    )
    expect(page).to have_content("Any subject - Grade C or above")
  end
  alias_method :and_i_see_the_subject_i_selected, :then_i_see_the_subject_i_selected

  def then_i_see_an_error_message_for_the_add_a_level_to_a_list_page
    and_i_see_there_is_a_problem
    expect(page).to have_content("Select if you want to add another A level or equivalent qualification").twice
  end

  def and_i_see_there_is_a_problem
    expect(page).to have_content("There is a problem")
  end

  def when_i_choose_any_stem_subject
    choose "Any STEM subject"
  end

  def then_i_see_the_two_subjects_i_already_added
    and_i_see_the_subject_i_selected
    expect(page).to have_content("Any STEM subject - Grade C or above")
  end

  def when_i_choose_any_humanities_subject
    choose "Any humanities subject"
  end

  def then_i_see_the_three_subjects_i_already_added
    then_i_see_the_two_subjects_i_already_added
    expect(page).to have_content("Any humanities subject")
  end

  def when_i_choose_other_subject
    choose "Choose a subject"
  end

  def and_i_select_mathematics
    select "Mathematics", from: "Subjects"
  end

  def then_i_see_the_four_subjects_i_already_added
    then_i_see_the_three_subjects_i_already_added
    expect(page).to have_content("Mathematics")
  end

  def and_i_do_not_see_the_option_to_add_more_a_level_subjects
    expect(page).to have_no_css("fieldset.govuk-fieldset")
    expect(page).to have_no_css("legend", text: "Do you want to add another A level or equivalent qualification?")
  end

  def then_i_am_on_the_add_another_a_level_subject_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
        @provider.provider_code,
        @provider.recruitment_cycle_year,
        @course.course_code,
      ),
      ignore_query: true,
    )
  end
  alias_method :and_i_am_on_the_add_another_a_level_subject_page, :then_i_am_on_the_add_another_a_level_subject_page

  def and_i_see_the_success_message_that_i_added_an_a_level
    expect(page).to have_content("You have added a required A level or equivalent qualification")
  end

  def then_i_am_on_the_consider_pending_a_level_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_consider_pending_a_level_path(
        @provider.provider_code,
        @provider.recruitment_cycle_year,
        @course.course_code,
      ),
    )
  end

  def then_i_see_an_error_message_for_the_consider_pending_a_level_page
    expect(page).to have_content("Select if you will consider candidates with pending A levels").twice
  end

  def then_i_am_on_a_level_equivalencies_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_a_level_equivalencies_path(
        @provider.provider_code,
        @provider.recruitment_cycle_year,
        @course.course_code,
      ),
    )
  end

  def when_i_click_update_a_levels
    click_on "Update A levels"
  end
  alias_method :and_i_click_update_a_levels, :when_i_click_update_a_levels

  def when_i_click_to_remove_the_a_level_subject
    click_on "Remove", match: :first
  end

  def recruitment_cycle_year
    RecruitmentCycle.current.year
  end
end
