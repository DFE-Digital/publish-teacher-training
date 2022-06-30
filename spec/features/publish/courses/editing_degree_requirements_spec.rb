# frozen_string_literal: true

require "rails_helper"

feature "Editing degree requirements", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "requires minimum degree classification" do
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_degrees_start_page
    and_i_require_a_classification
    then_i_should_see_the_degree_grade_page
    when_i_set_a_required_grade
    then_i_should_see_the_subject_requirements_page
    then_i_should_see_the_reuse_content
    when_i_set_additional_requirements
    then_i_should_see_a_success_message("degree requirements")
    and_the_required_grade_is_updated_with("two_one")
    and_the_additional_requirements_are_updated
  end

  scenario "does not require minimum degree classification" do
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_degrees_start_page
    and_i_do_not_require_a_classification
    then_i_should_see_the_subject_requirements_page
    when_i_set_additional_requirements
    then_i_should_see_a_success_message("degree requirements")
    and_the_required_grade_is_updated_with("not_required")
    and_the_additional_requirements_are_updated
  end

  context "primary course" do
    scenario "requires minimum degree classification" do
      and_there_is_a_primary_course_i_want_to_edit
      when_i_visit_the_degrees_start_page
      and_i_require_a_classification
      then_i_should_see_the_degree_grade_page
      when_i_set_a_required_grade
      then_i_should_see_a_success_message("minimum degree classification")
      and_the_required_grade_is_updated_with("two_one")
    end

    scenario "does not require minimum degree classification" do
      and_there_is_a_primary_course_i_want_to_edit
      when_i_visit_the_degrees_start_page
      and_i_do_not_require_a_classification
      then_i_should_see_a_success_message("minimum degree classification")
      and_the_required_grade_is_updated_with("not_required")
    end
  end

  context "start page" do
    scenario "pre-populates selected degree classification" do
      and_there_is_a_course_i_want_to_edit
      when_i_visit_the_degrees_start_page
      then_the_start_page_should_show_the_selected_classification
    end

    scenario "updating with invalid data" do
      given_a_course_exists(:secondary, degree_grade: nil)
      when_i_visit_the_degrees_start_page
      and_i_submit
      then_i_should_see_an_error_message("Select if you require a minimum degree classification")
    end
  end

  context "grade page" do
    scenario "pre-populates selected grade classification" do
      and_there_is_a_course_i_want_to_edit
      when_i_visit_the_degrees_grade_page
      then_the_grade_page_should_show_the_selected_grade
    end

    scenario "updating with invalid data" do
      given_a_course_exists(:secondary, degree_grade: nil)
      when_i_visit_the_degrees_grade_page
      and_i_submit
      then_i_should_see_an_error_message("Select the minimum degree classification you require")
    end
  end

  context "subject requirements page" do
    scenario "pre-populates additional subject requirements" do
      given_a_course_exists(:secondary, degree_subject_requirements: "Maths A Level")
      when_i_visit_the_degrees_subject_requirements_page
      then_the_subject_requirements_page_should_show_the_requirements
    end

    scenario "updating with invalid data" do
      given_a_course_exists(:secondary, degree_subject_requirements: nil)
      when_i_visit_the_degrees_subject_requirements_page
      and_i_submit
      then_i_should_see_an_error_message("Enter details of degree subject requirements")
    end

    context "copying content from another course" do
      let!(:course2) do
        create(
          :course,
          provider:,
          name: "Biology",
          additional_degree_subject_requirements: true,
          degree_subject_requirements: "Course 2 requirements",
        )
      end

      let!(:course3) do
        create(
          :course,
          provider:,
          name: "Biology",
          additional_degree_subject_requirements: nil,
          degree_subject_requirements: nil,
        )
      end

      scenario "all fields get copied if all are present" do
        given_a_course_exists(:secondary, degree_subject_requirements: "Maths A Level")
        when_i_visit_the_degrees_subject_requirements_page
        degree_subject_requirement_page.copy_content.copy(course2)

        [
          "Your changes are not yet saved",
          "Additional degree subject requirements",
          "Degree subject requirements",
        ].each do |name|
          expect(degree_subject_requirement_page.copy_content_warning).to have_content(name)
        end

        expect(degree_subject_requirement_page.yes_radio).to be_checked
        expect(degree_subject_requirement_page.no_radio).not_to be_checked
        expect(degree_subject_requirement_page.requirements.text).to eq(course2.degree_subject_requirements)
      end

      scenario "with all fields empty" do
        given_a_course_exists(:secondary, degree_subject_requirements: "Maths A Level")
        when_i_visit_the_degrees_subject_requirements_page
        degree_subject_requirement_page.copy_content.copy(course3)

        expect(degree_subject_requirement_page).not_to have_copy_content_warning
      end
    end
  end

  def then_i_should_see_the_reuse_content
    expect(degree_subject_requirement_page).to have_use_content
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(:secondary)
  end

  def and_there_is_a_primary_course_i_want_to_edit
    given_a_course_exists(:primary)
  end

  def when_i_visit_the_degrees_start_page
    degree_start_page.load(route_data)
  end

  def when_i_visit_the_degrees_grade_page
    degree_grade_page.load(route_data)
  end

  def when_i_visit_the_degrees_subject_requirements_page
    degree_subject_requirement_page.load(route_data)
  end

  def and_i_require_a_classification
    degree_start_page.yes_radio.choose
    and_i_submit
  end

  def and_i_do_not_require_a_classification
    degree_start_page.no_radio.choose
    and_i_submit
  end

  def then_i_should_see_the_degree_grade_page
    expect(degree_grade_page).to be_displayed
  end

  def when_i_set_a_required_grade
    degree_grade_page.two_one.choose
    and_i_submit
  end

  def then_i_should_see_the_subject_requirements_page
    expect(degree_subject_requirement_page).to be_displayed
  end

  def when_i_set_additional_requirements
    @some_additional_requiremet = "Some additional requirement"

    degree_subject_requirement_page.yes_radio.choose
    degree_subject_requirement_page.requirements.set(@some_additional_requiremet)
    and_i_submit
  end

  def and_i_submit
    course_requirement_edit_page.submit.click
  end

  def then_i_should_see_a_success_message(value)
    expect(page).to have_content I18n.t("success.value_saved", value:)
  end

  def and_the_additional_requirements_are_updated
    course.reload

    expect(course.additional_degree_subject_requirements).to be(true)
    expect(course.degree_subject_requirements).to eq(@some_additional_requiremet)
  end

  def and_the_required_grade_is_updated_with(grade)
    expect(course.reload.degree_grade).to eq(grade)
  end

  def then_the_start_page_should_show_the_selected_classification
    expect(degree_start_page.yes_radio).to be_checked
  end

  def then_the_grade_page_should_show_the_selected_grade
    expect(degree_grade_page.two_one).to be_checked
  end

  def then_the_subject_requirements_page_should_show_the_requirements
    expect(degree_subject_requirement_page.yes_radio).to be_checked
    expect(degree_subject_requirement_page.requirements.value).to eq("Maths A Level")
  end

  def then_i_should_see_an_error_message(message)
    expect(course_requirement_edit_page.error_messages).to include(message)
  end

  def provider
    @current_user.providers.first
  end

  def route_data
    { provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code }
  end
end
