# frozen_string_literal: true

require "rails_helper"

feature "Course show" do
  scenario "i can view the course basic details" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_published_course
    when_i_visit_the_course_details_page
    then_i_see_the_primary_course_basic_details
    and_i_do_not_see_engineers_teach_physics_row
  end

  context "Engineers Teach Physics course" do
    scenario "i can view the course basic details" do
      given_i_am_authenticated_as_a_provider_user
      and_there_is_a_published_physics_course
      when_i_visit_the_course_details_page
      then_i_see_the_secondary_course_basic_details
      and_i_see_engineers_teach_physics_row
    end
  end

  context "when cycle is current" do
    scenario "i can see the correct change links" do
      given_we_are_not_in_rollover
      and_i_am_authenticated_as_a_provider_user
      and_there_is_a_published_course
      when_i_visit_the_course_details_page
      then_i_see_the_correct_change_links
    end
  end

  context "when cycle is next" do
    scenario "i can see the correct change links" do
      given_we_are_in_rollover
      and_i_am_authenticated_as_a_provider_user_for_next_cycle
      and_there_is_a_published_course
      when_i_visit_the_course_details_page
      then_i_see_the_correct_change_links_for_the_next_cycle
    end
  end

private

  def given_we_are_not_in_rollover
    allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(false)
  end

  def given_we_are_in_rollover
    allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(true)
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end
  alias and_i_am_authenticated_as_a_provider_user given_i_am_authenticated_as_a_provider_user

  def and_i_am_authenticated_as_a_provider_user_for_next_cycle
    given_i_am_authenticated(user: create(:user, :with_provider_for_next_cycle))
  end

  def and_there_is_a_published_physics_course
    given_a_course_exists(:with_accrediting_provider, :secondary, start_date: Date.parse("2022 January"), enrichments: [build(:course_enrichment, :published)], subjects: [find_or_create(:secondary_subject, :physics)])
    given_a_site_exists(:full_time_vacancies, :findable)
  end

  def and_there_is_a_published_course
    given_a_course_exists(:with_accrediting_provider, start_date: Date.parse("2022 January"), enrichments: [build(:course_enrichment, :published)])
    given_a_site_exists(:full_time_vacancies, :findable)
  end

  def when_i_visit_the_course_details_page
    provider_courses_details_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_do_not_see_engineers_teach_physics_row
    expect(provider_courses_details_page).not_to have_engineers_teach_physics
  end

  def and_i_see_engineers_teach_physics_row
    expect(provider_courses_details_page).to have_engineers_teach_physics
    expect(provider_courses_details_page.engineers_teach_physics.key).to have_content("Engineers Teach Physics")
    expect(provider_courses_details_page.engineers_teach_physics.value).to have_content("No")
  end

  def and_i_see_the_common_course_basic_details
    expect(provider_courses_details_page.title).to have_content(
      "#{course.name} (#{course.course_code})",
    )

    expect(provider_courses_details_page).to have_course_button_panel

    expect(provider_courses_details_page.subjects).to have_content(
      course.subjects.sort.join,
    )
    expect(provider_courses_details_page.outcome).to have_content(
      "PGCE with QTS",
    )
    expect(provider_courses_details_page.study_mode).to have_content(
      "Full time",
    )
    expect(provider_courses_details_page.start_date).to have_content(
      "January 2022",
    )
    expect(provider_courses_details_page.start_date).to have_content(
      "Academic year 2021 to 2022",
    )
    expect(provider_courses_details_page.name).to have_content(
      course.name,
    )
    expect(provider_courses_details_page.description).to have_content(
      course.description,
    )
    expect(provider_courses_details_page.course_code).to have_content(
      course.course_code,
    )
    expect(provider_courses_details_page.locations).to have_content(
      course.sites.first.location_name,
    )

    expect(provider_courses_details_page.funding).to have_content(
      "Teaching apprenticeship - with salary",
    )
    expect(provider_courses_details_page.accredited_body).to have_content(
      course.accrediting_provider.provider_name,
    )
    expect(provider_courses_details_page.is_send).to have_content(
      "No",
    )
  end

  def then_i_see_the_secondary_course_basic_details
    expect(provider_courses_details_page.age_range).to have_content(
      "11 to 18",
    )

    expect(provider_courses_details_page.level).to have_content(
      "Secondary",
    )
    and_i_see_the_common_course_basic_details
  end

  def then_i_see_the_primary_course_basic_details
    expect(provider_courses_details_page.age_range).to have_content(
      "3 to 7",
    )

    expect(provider_courses_details_page.level).to have_content(
      "Primary",
    )
    and_i_see_the_common_course_basic_details
  end

  def then_i_see_the_correct_change_links
    expect(provider_courses_details_page.change_link_texts).to match_array([
      "subjects", "age range", "outcome", "if full or part time", "locations"
    ])
  end

  def then_i_see_the_correct_change_links_for_the_next_cycle
    expect(provider_courses_details_page.change_link_texts).to match_array([
      "subjects", "age range", "outcome", "if full or part time", "locations", "can sponsor skilled_worker visa"
    ])
  end

  def provider
    @current_user.providers.first
  end
end
