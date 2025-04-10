# frozen_string_literal: true

require "rails_helper"

feature "Copying course information", { can_edit_current_and_next_cycles: false } do
  context "with accredited courses" do
    before do
      given_i_am_authenticated_as_an_accredited_provider_user
      and_there_is_a_course_i_want_to_edit

      when_i_visit_the_how_school_placements_work_page
      then_i_see_the_current_course_information
    end

    include_context "copy_courses"

    scenario "the course does not display its own name in the copy list" do
      when_i_visit_the_how_school_placements_work_page
      then_the_correct_courses_are_available_to_select

      when_i_select_a_course_to_copy
      and_i_click_copy
      then_i_see_an_alert_that_the_changes_are_not_saved_yet
      and_i_can_see_the_new_content
    end
  end

  context "with non accredited courses" do
    before do
      given_i_am_authenticated_as_a_provider_user
      and_there_is_a_course_i_want_to_edit
      when_i_visit_the_how_school_placements_work_page
    end

    include_context "copy_courses"

    scenario "the course does not display its own name in the copy list" do
      when_i_visit_the_how_school_placements_work_page
      then_the_correct_courses_are_available_to_select
    end
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def given_i_am_authenticated_as_an_accredited_provider_user
    given_i_am_authenticated(user: create(:user, :with_accredited_provider))
  end

  def and_there_is_an_accredited_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def and_there_is_an_accredited_course_i_want_to_edit
    given_a_course_exists(:with_accrediting_provider, enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_how_school_placements_work_page
    visit school_placements_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      course.course_code,
    )
  end

  def then_i_see_the_current_course_information
    expect(page).to have_content(course.enrichments.first.how_school_placements_work)
  end

  def then_the_correct_courses_are_available_to_select
    list_options = publish_course_information_edit_page.copy_content.copy_options
    expect(Course.count).to eq 3
    expect(list_options.size).to eq 3
    expect(list_options.shift).to eq("Pick a course")
    expect(list_options.any? { |x| x[@course.name] }).to be_falsey
  end

  def when_i_select_a_course_to_copy
    list_options = publish_course_information_edit_page.copy_content.copy_options
    @course_to_copy = list_options.second
    select @course_to_copy, from: "Copy from"
  end

  def and_i_click_copy
    click_link_or_button "Copy content"
  end

  def then_i_see_an_alert_that_the_changes_are_not_saved_yet
    expect(page).to have_content "Your changes are not yet saved"
    expect(page).to have_content "We have copied this field from #{@course_to_copy}"
  end

  def and_i_can_see_the_new_content
    copied_course_code = @course_to_copy.match(/\((.*?)\)/)[1]
    @copied_course = Course.find_by(course_code: copied_course_code)
    expect(page).to have_content(@copied_course.enrichments.first.how_school_placements_work)
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
