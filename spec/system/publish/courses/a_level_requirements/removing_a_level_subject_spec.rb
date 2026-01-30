# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Removing A level subject requirements", travel: mid_cycle, type: :system do
  scenario "removing an A level subject requirement" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_tda_course_with_multiple_a_level_requirements

    when_i_visit_the_add_to_list_page
    then_i_see_the_existing_subjects

    when_i_click_remove_on_the_first_subject
    then_i_am_on_the_removal_confirmation_page
    and_i_see_the_subject_name_in_the_question

    when_i_click_continue
    then_i_see_the_confirmation_selection_error

    when_i_choose_no
    and_i_click_continue
    then_i_am_on_the_add_to_list_page
    and_all_subjects_remain

    when_i_click_remove_on_the_first_subject
    and_i_choose_yes
    and_i_click_continue
    then_i_am_on_the_add_to_list_page
    and_the_subject_is_removed
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, providers: [build(:provider, provider_type: "lead_school")])
    @provider = @user.providers.first
    given_i_am_authenticated(user: @user)
  end

  def and_i_have_a_tda_course_with_multiple_a_level_requirements
    @first_subject_uuid = SecureRandom.uuid
    @second_subject_uuid = SecureRandom.uuid
    @course = create(
      :course,
      :with_teacher_degree_apprenticeship,
      provider: @provider,
      a_level_subject_requirements: [
        { "uuid" => @first_subject_uuid, "subject" => "any_subject", "minimum_grade_required" => "C" },
        { "uuid" => @second_subject_uuid, "subject" => "any_stem_subject", "minimum_grade_required" => "B" },
      ],
      accept_pending_a_level: false,
      accept_a_level_equivalency: true,
    )
  end

  def when_i_visit_the_add_to_list_page
    visit publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
      @provider.provider_code,
      recruitment_cycle_year,
      @course.course_code,
    )
  end

  def then_i_see_the_existing_subjects
    expect(page).to have_content("Any subject - Grade C or above")
    expect(page).to have_content("Any STEM subject - Grade B or above")
  end

  def when_i_click_remove_on_the_first_subject
    click_on "Remove", match: :first
  end

  def then_i_am_on_the_removal_confirmation_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_remove_a_level_subject_confirmation_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
        uuid: @first_subject_uuid,
      ),
    )
  end

  def and_i_see_the_subject_name_in_the_question
    expect(page).to have_content("Are you sure you want to remove Any subject?")
  end

  def when_i_click_continue
    click_on "Continue"
  end
  alias_method :and_i_click_continue, :when_i_click_continue

  def then_i_see_the_confirmation_selection_error
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select if you want to remove Any subject")
  end

  def when_i_choose_no
    choose "No"
  end

  def and_all_subjects_remain
    expect(@course.reload.a_level_subject_requirements.size).to eq(2)
    expect(page).to have_content("Any subject - Grade C or above")
    expect(page).to have_content("Any STEM subject - Grade B or above")
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

  def when_i_choose_yes
    choose "Yes"
  end
  alias_method :and_i_choose_yes, :when_i_choose_yes

  def and_the_subject_is_removed
    expect(@course.reload.a_level_subject_requirements.size).to eq(1)
    expect(page).to have_no_content("Any subject - Grade C or above")
    expect(page).to have_content("Any STEM subject - Grade B or above")
  end

  def recruitment_cycle_year
    RecruitmentCycle.current.year
  end
end
