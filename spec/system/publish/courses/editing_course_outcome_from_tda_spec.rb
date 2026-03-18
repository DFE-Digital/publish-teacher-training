# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing course outcome from TDA" do
  scenario "changing to QTS while keeping apprenticeship shows degree requirements again" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_tda_course_i_want_to_edit
    and_i_see_the_tda_requirements_on_the_course_description_tab

    when_i_visit_the_course_outcome_page
    and_i_choose_qts
    and_i_choose_apprenticeship
    and_i_choose_part_time
    and_i_choose_to_sponsor_a_skilled_worker_visa

    then_i_see_the_correct_attributes_in_the_database_for_apprenticeship
    and_i_see_the_degree_requirements_row_on_the_course_description_tab
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @current_user = create(:user, :with_provider)
    given_i_am_authenticated(user: @current_user)
  end

  def and_there_is_a_tda_course_i_want_to_edit
    @course = create(
      :course,
      :with_teacher_degree_apprenticeship,
      :draft_enrichment,
      provider: provider,
      study_mode: "full_time",
      degree_type: "undergraduate",
      degree_grade: "two_one",
      degree_subject_requirements: "Subject knowledge requirement for system test",
    )
  end

  def when_i_visit_the_course_outcome_page
    publish_courses_outcome_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
  end

  def and_i_choose_qts
    publish_courses_outcome_edit_page.qts.choose
    publish_courses_outcome_edit_page.submit.click
  end

  def and_i_choose_apprenticeship
    choose "Teaching apprenticeship - with salary"
    click_on "Update funding type"
  end

  def and_i_choose_part_time
    uncheck "Full time"
    check "Part time"
    click_on "Update"
  end

  def and_i_choose_to_sponsor_a_skilled_worker_visa
    choose "Yes"
    click_on "Update"
  end

  def then_i_see_the_correct_attributes_in_the_database_for_apprenticeship
    course.reload

    expect(course.qts?).to be(true)
    expect(course.postgraduate_degree_type?).to be(true)
    expect(course.funding).to eq("apprenticeship")
    expect(course.program_type).to eq("pg_teaching_apprenticeship")
    expect(course.teacher_degree_apprenticeship?).to be(false)
    expect(course.can_sponsor_skilled_worker_visa).to be(true)
  end

  def and_i_see_the_tda_requirements_on_the_course_description_tab
    when_i_visit_the_course_description_tab

    expect(page).to have_link("Enter A levels and equivalency test requirements")
    expect(page).not_to have_content("Subject knowledge requirement for system test")
  end

  def and_i_see_the_degree_requirements_row_on_the_course_description_tab
    when_i_visit_the_course_description_tab

    expect(page).to have_content("Subject knowledge requirement for system test")
    expect(page).not_to have_link("Enter A levels and equivalency test requirements")
  end

  def when_i_visit_the_course_description_tab
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
    publish_provider_courses_show_page.description_link.click
  end

  def provider
    @current_user.providers.first
  end

  attr_reader :course
end
