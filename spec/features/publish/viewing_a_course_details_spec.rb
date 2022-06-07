# frozen_string_literal: true

require "rails_helper"

feature "Course show", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_course_details_page
  end

  scenario "i can view the course basic details" do
    then_i_see_the_course_basic_details
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, courses: [build(:course, :with_accrediting_provider, start_date: Date.parse("2022 January"))]),
        ],
      ),
    )
  end

  def when_i_visit_the_course_details_page
    publish_provider_courses_details_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def then_i_see_the_course_basic_details
    expect(publish_provider_courses_details_page.caption).to have_content(
      course.description,
    )
    expect(publish_provider_courses_details_page.title).to have_content(
      "#{course.name} (#{course.course_code})",
    )
    expect(publish_provider_courses_details_page.subjects).to have_content(
      course.subjects.sort.join,
    )
    expect(publish_provider_courses_details_page.age_range).to have_content(
      "3 to 7",
    )

    expect(publish_provider_courses_details_page.outcome).to have_content(
      "PGCE with QTS",
    )
    expect(publish_provider_courses_details_page.study_mode).to have_content(
      "Full time",
    )
    expect(publish_provider_courses_details_page.start_date).to have_content(
      "January 2022",
    )
    expect(publish_provider_courses_details_page.name).to have_content(
      course.name,
    )
    expect(publish_provider_courses_details_page.description).to have_content(
      course.description,
    )
    expect(publish_provider_courses_details_page.course_code).to have_content(
      course.course_code,
    )
    expect(publish_provider_courses_details_page.locations).to have_content(
      "None",
    )

    # expect(course_details_page).to have_no_manage_provider_locations_link
    # expect(course_details_page).to have_no_apprenticeship
    expect(publish_provider_courses_details_page.funding).to have_content(
      "Teaching apprenticeship (with salary)",
    )
    expect(publish_provider_courses_details_page.accredited_body).to have_content(
      course.accrediting_provider.provider_name,
    )
    expect(publish_provider_courses_details_page.is_send).to have_content(
      "No",
    )
    expect(publish_provider_courses_details_page.level).to have_content(
      "Primary",
    )
  end

  def provider
    @current_user.providers.first
  end

  def course
    provider.courses.first
  end
end
