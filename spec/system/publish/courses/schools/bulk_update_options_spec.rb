# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish - Choosing which courses a placement school change applies to", type: :system do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  describe "the options offered" do
    scenario "a fee-paying secondary course can be applied by funding, phase or subject" do
      given_a_course(:secondary, funding: :fee, subject: :biology)
      when_i_choose_which_courses_to_apply_the_change_to

      then_the_options_are(
        "Only this course - #{course.name_and_code}",
        "All fee-paying courses",
        "All secondary courses",
        "All biology courses",
        "All courses",
      )
      and_the_or_divider_follows_the_first_option
      and_nothing_is_chosen_for_me
    end

    scenario "a salaried course is named as school direct salaried" do
      given_a_course(:secondary, funding: :salary)
      when_i_choose_which_courses_to_apply_the_change_to

      then_the_options_include("All school direct salaried courses")
    end

    scenario "an apprenticeship course is named as an apprenticeship" do
      given_a_course(:secondary, funding: :apprenticeship)
      when_i_choose_which_courses_to_apply_the_change_to

      then_the_options_include("All apprenticeship courses")
    end

    scenario "a primary course has no phase to offer and is named by its level" do
      given_a_course(:primary)
      when_i_choose_which_courses_to_apply_the_change_to

      then_the_options_include("All primary courses")
      and_the_options_do_not_include("All secondary courses")
    end

    scenario "a further education course is named by its level" do
      given_a_course(:further_education)
      when_i_choose_which_courses_to_apply_the_change_to

      then_the_options_include("All further education courses")
    end

    scenario "the course is described under only this course" do
      given_a_course(:secondary, funding: :fee)
      when_i_choose_which_courses_to_apply_the_change_to

      then_i_see_the_hint("Fee-paying, #{course.qualifications_summary}, full time")
    end

    scenario "a salaried course calls them employing schools" do
      given_a_course(:secondary, funding: :salary)
      when_i_choose_which_courses_to_apply_the_change_to

      expect(page).to have_content("Updating employing schools")
    end
  end

  describe "answering" do
    before do
      given_a_course(:secondary, funding: :fee, subject: :biology)
    end

    scenario "the question has to be answered" do
      when_i_choose_which_courses_to_apply_the_change_to
      and_i_continue

      then_i_see_the_error("Select what courses you want to apply this change to")
    end

    scenario "only this course changes that course alone" do
      and_another_fee_paying_course_exists
      when_i_choose_which_courses_to_apply_the_change_to
      and_i_choose("Only this course - #{course.name_and_code}")
      and_i_continue

      then_i_am_on_the_basic_details_page
      and_the_course_has("Ash Academy", "Beech School", "Cedar School")
      and_the_other_course_still_has("Ash Academy")
    end

    scenario "a bulk option goes on to review the courses it will update" do
      and_another_fee_paying_course_exists
      when_i_choose_which_courses_to_apply_the_change_to
      and_i_choose("All fee-paying courses")
      and_i_continue

      then_i_see_the_courses_that_will_be_updated
      and_nothing_has_been_written_yet
    end

    scenario "the selection cannot be applied twice" do
      when_i_choose_which_courses_to_apply_the_change_to
      options_page = page.current_path
      and_i_choose("Only this course - #{course.name_and_code}")
      and_i_continue
      and_i_return_to(options_page)

      then_i_am_told_my_selection_has_expired
    end
  end

private

  attr_reader :provider, :course, :other_course

  def school_names
    ["Ash Academy", "Beech School", "Cedar School"]
  end

  def given_i_am_authenticated_as_a_provider_user
    @provider = create(:provider)
    school_names.each { |location_name| create(:site, :with_provider_school, provider: @provider, location_name:) }
    given_i_am_authenticated(user: create(:user, providers: [@provider]))
    @provider.reload
  end

  def given_a_course(level, funding: :fee, subject: nil)
    subjects = subject ? [find_or_create(:secondary_subject, subject)] : []
    @course = create(:course, level, provider:, funding:, sites: [], **(subjects.any? ? { subjects: } : {}))
    attach("Ash Academy", to: @course)
    attach("Beech School", to: @course)
  end

  def and_another_fee_paying_course_exists
    @other_course = create(:course, :secondary, provider:, funding: :fee, sites: [])
    attach("Ash Academy", to: @other_course)
  end

  def attach(location_name, to:)
    provider_school = provider.schools.joins(:gias_school).find_by!(gias_school: { name: location_name })
    create(:course_school, course: to, provider_school:, gias_school: provider_school.gias_school)
  end

  def when_i_choose_which_courses_to_apply_the_change_to
    publish_course_school_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
    check "Cedar School"
    publish_course_school_edit_page.submit.click
  end

  def and_i_choose(label)
    choose label
  end

  def and_i_continue
    click_button "Continue to view the courses that will be updated"
  end

  def and_i_return_to(path)
    visit path
  end

  def then_the_options_are(*labels)
    expect(publish_course_school_bulk_update_page.scope_labels).to eq(labels)
  end

  def then_the_options_include(*labels)
    expect(publish_course_school_bulk_update_page.scope_labels).to include(*labels)
  end

  def and_the_options_do_not_include(label)
    expect(publish_course_school_bulk_update_page.scope_labels).not_to include(label)
  end

  def and_the_or_divider_follows_the_first_option
    expect(publish_course_school_bulk_update_page.divider_position).to eq(1)
  end

  def and_nothing_is_chosen_for_me
    expect(page).to have_no_css(".govuk-radios__input[checked]")
  end

  def then_i_see_the_hint(text)
    expect(page).to have_css(".govuk-hint", text:)
  end

  def then_i_see_the_error(message)
    expect(publish_course_school_bulk_update_page.error_summary).to have_content(message)
  end

  def then_i_am_on_the_basic_details_page
    expect(page).to have_current_path(
      details_publish_provider_recruitment_cycle_course_path(
        provider.provider_code,
        provider.recruitment_cycle_year,
        course.course_code,
      ),
    )
  end

  def then_i_see_the_courses_that_will_be_updated
    expect(page).to have_content("You are updating these courses:")
  end

  def and_nothing_has_been_written_yet
    expect(attached_names(course)).to contain_exactly("Ash Academy", "Beech School")
    expect(attached_names(other_course)).to contain_exactly("Ash Academy")
  end

  def then_i_am_told_my_selection_has_expired
    expect(page).to have_content("Your school selection has expired")
  end

  def and_the_course_has(*names)
    expect(attached_names(course)).to match_array(names)
  end

  def and_the_other_course_has(*names)
    expect(attached_names(other_course)).to match_array(names)
  end
  alias_method :and_the_other_course_still_has, :and_the_other_course_has

  def attached_names(a_course)
    a_course.reload.schools.joins(:gias_school).pluck("gias_school.name")
  end
end
