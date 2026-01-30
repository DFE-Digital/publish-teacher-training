# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing A level subject requirements", travel: mid_cycle, type: :system do
  scenario "editing an existing A level subject requirement" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_tda_course_with_a_level_requirements

    when_i_visit_the_course_description_tab
    and_i_click_to_change_a_levels
    then_i_am_on_the_add_to_list_page
    and_i_see_the_existing_subjects

    when_i_click_change_on_the_first_subject
    then_i_am_on_the_edit_page_for_that_subject
    and_the_back_link_points_to_add_to_list_page
    and_the_form_is_pre_filled_with_existing_values

    when_i_change_the_subject_to_any_science
    and_i_change_the_grade_to_b
    and_i_click_continue
    then_i_am_on_the_add_to_list_page
    and_the_subject_is_updated
    and_no_duplicate_was_created
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, providers: [build(:provider, provider_type: "lead_school")])
    @provider = @user.providers.first
    given_i_am_authenticated(user: @user)
  end

  def and_i_have_a_tda_course_with_a_level_requirements
    @subject_uuid = SecureRandom.uuid
    @course = create(
      :course,
      :with_teacher_degree_apprenticeship,
      provider: @provider,
      a_level_subject_requirements: [
        { "uuid" => @subject_uuid, "subject" => "any_subject", "minimum_grade_required" => "C" },
        { "uuid" => SecureRandom.uuid, "subject" => "any_stem_subject", "minimum_grade_required" => "B" },
      ],
      accept_pending_a_level: false,
      accept_a_level_equivalency: true,
    )
  end

  def when_i_visit_the_course_description_tab
    publish_provider_courses_show_page.load(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: recruitment_cycle_year,
      course_code: @course.course_code,
    )
  end

  def and_i_click_to_change_a_levels
    click_on "Change A levels"
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

  def and_i_see_the_existing_subjects
    expect(page).to have_content("Any subject - Grade C or above")
    expect(page).to have_content("Any STEM subject - Grade B or above")
  end

  def when_i_click_change_on_the_first_subject
    click_on "Change", match: :first
  end

  def then_i_am_on_the_edit_page_for_that_subject
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_edit_a_levels_what_a_level_is_required_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
        uuid: @subject_uuid,
      ),
    )
  end

  def and_the_back_link_points_to_add_to_list_page
    expect(page.find_link(text: "Back")[:href]).to eq(
      publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
        @provider.provider_code,
        recruitment_cycle_year,
        @course.course_code,
      ),
    )
  end

  def and_the_form_is_pre_filled_with_existing_values
    expect(page).to have_checked_field("what-a-level-is-required-subject-any-subject-field")
    expect(find_field("Minimum grade required (optional)").value).to eq("C")
  end

  def when_i_change_the_subject_to_any_science
    choose "Any science subject"
  end

  def and_i_change_the_grade_to_b
    fill_in "Minimum grade required (optional)", with: "B"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def and_the_subject_is_updated
    expect(page).to have_content("Any science subject - Grade B or above")
    # The original "Any subject" should be replaced, not duplicated
    updated_requirement = @course.reload.a_level_subject_requirements.find { |r| r["uuid"] == @subject_uuid }
    expect(updated_requirement["subject"]).to eq("any_science_subject")
    expect(updated_requirement["minimum_grade_required"]).to eq("B")
  end

  def and_no_duplicate_was_created
    expect(@course.reload.a_level_subject_requirements.size).to eq(2)
  end

  def recruitment_cycle_year
    RecruitmentCycle.current.year
  end
end
