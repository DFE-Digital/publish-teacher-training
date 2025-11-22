# frozen_string_literal: true

require "rails_helper"

feature "Editing about this course from the course preview page" do
  scenario "I am redirected back to the course page", travel: mid_cycle(2025) do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit

    when_i_visit_the_about_this_course_preview_page
    and_i_click_what_you_will_study_missing_link
    then_i_see_the_what_you_will_study_page

    when_i_add_what_you_will_study_content
    and_i_submit_the_form
    then_i_am_on_the_course_page
    and_i_see_the_what_you_will_study_change_i_made
  end

private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(
      funding: "salary",
      enrichments: [build(:course_enrichment, :published, about_course: nil)],
    )
  end

  def when_i_visit_the_about_this_course_preview_page
    visit preview_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code,
    )
  end

  def and_i_click_what_you_will_study_missing_link
    click_on "Enter details about what you will study"
  end

  def then_i_see_the_what_you_will_study_page
    expect(page).to have_content "What you will study"
    expect(page).to have_current_path fields_what_you_will_study_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code,
    ), ignore_query: true
  end

  def when_i_add_what_you_will_study_content
    fill_in "What will trainees do during their theoretical training?", with: "La la la, what you will study"
  end

  def and_i_submit_the_form
    click_on "Update what you will study"
  end

  def then_i_am_on_the_course_page
    expect(page).to have_current_path publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code,
    ), ignore_query: true
  end

  def and_i_see_the_what_you_will_study_change_i_made
    expect(page).to have_content "La la la, what you will study"
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
