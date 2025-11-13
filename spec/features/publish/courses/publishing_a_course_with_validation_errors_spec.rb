# frozen_string_literal: true

require "rails_helper"

feature "Publishing courses errors" do
  scenario "The error links target the correct pages" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_an_invalid_course_i_want_to_publish

    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_see_validation_errors

    when_i_click_the_publish_link
    and_i_click_the_theoretical_training_activities_error
    then_i_am_on_the_what_you_will_study_page
    when_i_complete_theoretical_training_activities
    then_i_am_on_the_course_page

    when_i_click_the_publish_link
    and_i_click_the_placement_school_activities_error
    then_i_am_on_the_where_you_will_train_page
    when_i_complete_placement_school_activities
    then_i_am_on_the_course_page

    when_i_click_the_publish_link
    and_i_click_the_what_you_will_do_on_placements_error
    then_i_am_on_the_school_placement_page
    when_i_complete_what_you_will_do_on_placements
    then_i_am_on_the_course_page

    when_i_click_the_publish_link
    and_i_click_the_course_length_error
    then_i_am_on_the_course_length_page
    when_i_complete_the_course_length
    then_i_am_on_the_course_page

    when_i_click_the_publish_link
    and_i_click_the_salary_error
    then_i_am_on_the_course_salary_page
    when_i_complete_the_course_salary
    then_i_am_on_the_course_page

    when_i_click_the_publish_link
    and_i_click_the_degree_error
    then_i_am_on_the_degrees_page
    when_i_complete_the_degree_requirements
    then_i_am_on_the_course_page

    when_i_click_the_publish_link
    and_i_click_the_gcse_error
    then_i_am_on_the_gcse_page
    when_i_complete_the_gcse_requirements

    then_i_am_on_the_course_page

    and_i_click_the_publish_link
    then_i_see_a_success_message
  end

  def then_i_see_a_success_message
    expect(page).to have_content("Your course has been published.")
  end

  def when_i_complete_the_course_length
    choose "1 year"
    click_link_or_button "Update course length"
  end

  def when_i_complete_the_course_salary
    fill_in "publish-course-salary-form-salary-details-field-error", with: "About course salary details"
    click_link_or_button "Save"
  end

  def when_i_complete_the_gcse_requirements
    choose "Yes", id: "publish-gcse-requirements-form-accept-pending-gcse-field-error"
    choose "No", id: "publish-gcse-requirements-form-accept-gcse-equivalency-field"
    click_link_or_button "Update GCSEs and equivalency tests"
  end

  def when_i_complete_the_degree_requirements
    choose "No"
    click_link_or_button "Save"
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def then_i_see_validation_errors
    within ".govuk-error-summary" do
      expect(page).to have_content("Enter a course length")
      expect(page).to have_content("Enter details about the salary for this course")
      expect(page).to have_content("Enter degree requirements")
      expect(page).to have_content("Enter GCSE requirements")
    end
  end

  def and_i_click_the_what_you_will_do_on_placements_error
    within ".govuk-error-summary" do
      page.find_link("Enter what will trainees do while in their placement schools").click
    end
  end

  def then_i_am_on_the_school_placement_page
    expect(page).to have_current_path(/fields\/school-placement/, ignore_query: true)
    expect(page).to have_content("What you will do on school placements")
  end

  def and_i_click_the_placement_school_activities_error
    within ".govuk-error-summary" do
      page.find_link("Enter how you decide which schools to place trainees in").click
    end
  end

  def when_i_complete_what_you_will_do_on_placements
    fill_in "What will trainees do while in their placement schools?", with: "learn"
    click_link_or_button "Update what you will do on school placements"
  end

  def then_i_am_on_the_where_you_will_train_page
    expect(page).to have_current_path(/fields\/where-you-will-train/, ignore_query: true)
    expect(page).to have_content("Where you will train")
  end

  def when_i_complete_placement_school_activities
    fill_in "How do you decide which schools to place trainees in?", with: "Observe, team-teach, plan and deliver lessons"
    fill_in "How much time will they spend in each school?", with: "12 weeks per school"

    click_link_or_button "Update where you will train"
  end

  def and_i_click_the_theoretical_training_activities_error
    within ".govuk-error-summary" do
      page.find_link("Enter details about theoretical training activities").click
    end
  end

  def then_i_am_on_the_what_you_will_study_page
    expect(page).to have_current_path(/fields\/what-you-will-study/, ignore_query: true)
    expect(page).to have_content("What you will study")
  end

  def when_i_complete_theoretical_training_activities
    fill_in "What will trainees do during their theoretical training?", with: "Curriculum design, assessment theory, and pedagogy seminars"
    click_link_or_button "Update what you will study"
  end

  def and_i_click_the_course_length_error
    within ".govuk-error-summary" do
      page.find_link("Enter a course length").click
    end
  end

  def and_i_click_the_salary_error
    within ".govuk-error-summary" do
      page.find_link("Enter details about the salary for this course").click
    end
  end

  def and_i_click_the_degree_error
    within ".govuk-error-summary" do
      page.find_link("Enter degree requirements").click
    end
  end

  def and_i_click_the_gcse_error
    within ".govuk-error-summary" do
      page.find_link("Enter GCSE requirements").click
    end
  end

  def then_i_am_on_the_course_length_page
    expect(page).to have_current_path(/length/)
  end

  def then_i_am_on_the_course_salary_page
    expect(page).to have_current_path(/salary/)
  end

  def then_i_am_on_the_degrees_page
    expect(page).to have_current_path(%r{degrees/start})
  end

  def then_i_am_on_the_gcse_page
    expect(page).to have_current_path(/gcses-pending-or-equivalency-tests/)
  end

  def and_there_is_an_invalid_course_i_want_to_publish
    given_a_course_exists(
      :with_accrediting_provider,
      :salary,
      degree_grade: nil,
      accrediting_provider:,
      enrichments: [create(:course_enrichment, :without_content, about_course: "")],
      sites: [create(:site, location_name: "location 1")],
      study_sites: [create(:site, :study_site)],
    )
  end

  def when_i_visit_the_course_page
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def then_i_am_on_the_course_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}")
  end

  def and_i_click_the_publish_link
    publish_provider_courses_show_page.course_button_panel.publish_button.click
  end
  alias_method :when_i_click_the_publish_link, :and_i_click_the_publish_link

  def accrediting_provider
    build(:accredited_provider)
  end

  def provider
    @current_user.providers.first
  end
end
