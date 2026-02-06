# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Removing all A level subject requirements", travel: mid_cycle, type: :system do
  scenario "removing the last A level subject redirects to the course page" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_tda_course_with_one_a_level_requirement

    when_i_visit_the_add_to_list_page
    then_i_see_the_existing_subject

    when_i_click_remove
    then_i_am_on_the_removal_confirmation_page

    when_i_choose_yes
    and_i_click_continue
    then_i_am_on_the_course_description_page
    and_the_a_level_requirements_are_cleared
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, providers: [build(:provider, provider_type: "lead_school")])
    @provider = @user.providers.first
    given_i_am_authenticated(user: @user)
  end

  def and_i_have_a_tda_course_with_one_a_level_requirement
    @subject_uuid = SecureRandom.uuid
    @course = create(
      :course,
      :with_teacher_degree_apprenticeship,
      provider: @provider,
      a_level_subject_requirements: [
        { "uuid" => @subject_uuid, "subject" => "any_subject", "minimum_grade_required" => "C" },
      ],
      accept_pending_a_level: true,
      accept_a_level_equivalency: true,
      additional_a_level_equivalencies: "We accept equivalent qualifications",
    )
  end

  def when_i_visit_the_add_to_list_page
    visit publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
      @provider.provider_code,
      recruitment_cycle_year,
      @course.course_code,
    )
  end

  def then_i_see_the_existing_subject
    expect(page).to have_content("Any subject - Grade C or above")
  end

  def when_i_click_remove
    click_on "Remove"
  end

  def then_i_am_on_the_removal_confirmation_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_remove_a_level_subject_confirmation_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
        uuid: @subject_uuid,
      ),
    )
  end

  def when_i_choose_yes
    choose "Yes"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_on_the_course_description_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
      ),
    )
  end

  def and_the_a_level_requirements_are_cleared
    @course.reload
    expect(@course.a_level_subject_requirements).to be_empty
  end

  def recruitment_cycle_year
    RecruitmentCycle.current.year
  end
end
