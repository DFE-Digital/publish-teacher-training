# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adding A levels validation errors", travel: mid_cycle, type: :system do
  scenario "validation errors when adding A level requirements" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_tda_course

    # What A level is required page validation
    when_i_visit_the_what_a_level_is_required_page
    and_i_click_continue
    then_i_see_the_subject_selection_error

    when_i_choose_other_subject
    and_i_click_continue
    then_i_see_the_subject_selection_error

    # Add to list page validation
    when_i_add_a_valid_subject
    and_i_click_continue
    then_i_am_on_the_add_to_list_page

    when_i_click_continue
    then_i_see_the_add_another_selection_error

    # Validation with subject already added - test dropdown validation
    when_i_choose_to_add_another
    and_i_click_continue
    then_i_am_on_the_what_a_level_is_required_page

    when_i_choose_other_subject
    and_i_click_continue
    then_i_see_the_subject_selection_error

    when_i_select_a_subject_from_dropdown
    and_i_click_continue
    then_i_am_on_the_add_to_list_page
    and_i_see_both_subjects

    # Equivalencies page validation
    when_i_complete_subjects_and_pending_steps
    then_i_am_on_the_equivalencies_page

    when_i_choose_yes
    and_i_add_too_many_words_into_equivalency_details
    and_i_click_update_a_levels
    then_i_see_the_word_limit_error
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

  def and_i_click_continue
    click_on "Continue"
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def then_i_see_the_subject_selection_error
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a subject").twice
  end

  def when_i_choose_other_subject
    choose "Choose a subject"
  end

  def when_i_add_a_valid_subject
    choose "Any subject"
    fill_in "Minimum grade required (optional)", with: "C"
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

  def when_i_choose_to_add_another
    choose "Yes"
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

  def when_i_select_a_subject_from_dropdown
    select "Mathematics", from: "Subjects"
  end

  def and_i_see_both_subjects
    expect(page).to have_content("Any subject - Grade C or above")
    expect(page).to have_content("Mathematics")
  end

  def then_i_see_the_add_another_selection_error
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select if you want to add another A level or equivalent qualification").twice
  end

  def when_i_complete_subjects_and_pending_steps
    choose "No"
    click_on "Continue"
    choose "No"
    click_on "Continue"
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

  def and_i_add_too_many_words_into_equivalency_details
    fill_in "Details about equivalency tests you offer or accept",
            with: "words " * (ALevelsWizard::Steps::ALevelEquivalencies::MAXIMUM_ADDITIONAL_A_LEVEL_EQUIVALENCY_WORDS + 2)
  end

  def and_i_click_update_a_levels
    click_on "Update A levels"
  end

  def then_i_see_the_word_limit_error
    expect(page).to have_content("Details about equivalency tests must be 250 words or less. You have 2 words too many")
  end

  def recruitment_cycle_year
    RecruitmentCycle.current.year
  end
end
