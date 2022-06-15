# frozen_string_literal: true

require "rails_helper"

feature "Course show", { can_edit_current_and_next_cycles: false } do
  scenario "i can view the course basic details" do
    given_i_am_authenticated_as_a_provider_user(course: build(:course))
    when_i_visit_the_course_page
    and_i_click_on_basic_details
    then_i_see_the_course_basic_details
  end

  describe "with a fee paying course" do
    scenario "i can view a fee course" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [course_enrichment], funding_type: "fee"))
      when_i_visit_the_course_page
      then_i_should_see_the_description_of_the_fee_course
      and_i_should_see_the_status_sidebar
    end
  end

  describe "with a salary paying course" do
    scenario "i can view a salary course" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [course_enrichment], funding_type: "salary"))
      when_i_visit_the_course_page
      then_i_should_see_the_description_of_the_salary_course
      and_i_should_see_the_status_sidebar
    end
  end

  describe "with a published and running course" do
    scenario "i can view the published partial" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [course_enrichment], funding_type: "salary", site_statuses: [build(:site_status, :findable)]))
      when_i_visit_the_course_page
      then_i_should_see_the_description_of_the_salary_course
      and_i_should_see_the_status_sidebar
      and_i_should_see_the_published_partial
    end
  end

  describe "with a published with unpublished changes course" do
    scenario "i can view the unpublished partial" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [course_enrichment_unpublished_changes], funding_type: "salary"))
      when_i_visit_the_course_page
      then_i_should_see_the_description_of_the_unpublished_changes_course
      and_i_should_see_the_status_sidebar
      and_i_should_see_the_unpublished_partial
    end
  end

  describe "with an inital draft course" do
    scenario "i can view the unpublished partial" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [course_enrichment_initial_draft], funding_type: "salary"))
      when_i_visit_the_course_page
      then_i_should_see_the_description_of_the_initial_draft_course
      and_i_should_see_the_status_sidebar
      and_i_should_see_the_unpublished_partial
    end
  end

  def and_i_should_see_the_status_sidebar
    expect(provider_courses_show_page).to have_status_sidebar
  end

  def and_i_should_see_the_unpublished_partial
    provider_courses_show_page.status_sidebar.within do |status_sidebar|
      expect(status_sidebar).to have_unpublished_partial
    end
  end

  def and_i_should_see_the_published_partial
    provider_courses_show_page.status_sidebar.within do |status_sidebar|
      expect(status_sidebar).to have_published_partial
    end
  end

  def and_i_click_on_basic_details
    provider_courses_show_page.basic_details_link.click
  end

  def then_i_see_the_course_basic_details
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}/details")
  end

  def course_enrichment
    @course_enrichment ||= build(:course_enrichment, :published, course_length: :TwoYears, fee_uk_eu: 9250, fee_international: 14000)
  end

  def course_enrichment_unpublished_changes
    @course_enrichment_unpublished_changes ||= build(:course_enrichment, :subsequent_draft, course_length: :TwoYears, fee_uk_eu: 9250, fee_international: 14000)
  end

  def course_enrichment_initial_draft
    @course_enrichment_initial_draft ||= build(:course_enrichment, :initial_draft)
  end

  def given_i_am_authenticated_as_a_provider_user(course:)
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, sites: [build(:site)], courses: [course]),
        ],
      ),
    )
  end

  def when_i_visit_the_course_page
    provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def then_i_should_see_the_description_of_the_unpublished_changes_course
    expect(provider_courses_show_page.about_course).to have_content(
      course_enrichment_unpublished_changes.about_course,
    )
  end

  def then_i_should_see_the_description_of_the_initial_draft_course
    expect(provider_courses_show_page.about_course).to have_content(
      course_enrichment_initial_draft.about_course,
    )
  end

  def then_i_should_see_the_description_of_the_fee_course
    expect(provider_courses_show_page.caption).to have_content(
      course.description,
    )
    expect(provider_courses_show_page.title).to have_content(
      "#{course.name} (#{course.course_code})",
    )
    expect(provider_courses_show_page.about_course).to have_content(
      course_enrichment.about_course,
    )
    expect(provider_courses_show_page.interview_process).to have_content(
      course_enrichment.interview_process,
    )
    expect(provider_courses_show_page.how_school_placements_work).to have_content(
      course_enrichment.how_school_placements_work,
    )
    expect(provider_courses_show_page.course_length).to have_content(
      "Up to 2 years",
    )
    expect(provider_courses_show_page.fee_uk_eu).to have_content(
      "£9,250",
    )
    expect(provider_courses_show_page.fee_international).to have_content(
      "£14,000",
    )
    expect(provider_courses_show_page.fee_details).to have_content(
      course_enrichment.fee_details,
    )
    expect(provider_courses_show_page).not_to have_salary_details

    expect(provider_courses_show_page).to have_degree
    expect(provider_courses_show_page).to have_gcse

    expect(provider_courses_show_page.personal_qualities).to have_content(
      course_enrichment.personal_qualities,
    )
    expect(provider_courses_show_page.other_requirements).to have_content(
      course_enrichment.other_requirements,
    )
  end

  def then_i_should_see_the_description_of_the_salary_course
    expect(provider_courses_show_page.caption).to have_content(
      course.description,
    )
    expect(provider_courses_show_page.title).to have_content(
      "#{course.name} (#{course.course_code})",
    )
    expect(provider_courses_show_page.about_course).to have_content(
      course_enrichment.about_course,
    )
    expect(provider_courses_show_page.interview_process).to have_content(
      course_enrichment.interview_process,
    )
    expect(provider_courses_show_page.how_school_placements_work).to have_content(
      course_enrichment.how_school_placements_work,
    )
    expect(provider_courses_show_page.course_length).to have_content(
      "Up to 2 years",
    )
    expect(provider_courses_show_page).not_to have_fee_uk_eu

    expect(provider_courses_show_page).not_to have_fee_international

    expect(provider_courses_show_page).not_to have_fee_details
    expect(provider_courses_show_page.salary_details).to have_content(
      course_enrichment.salary_details,
    )
    expect(provider_courses_show_page).to have_degree
    expect(provider_courses_show_page).to have_gcse
    expect(provider_courses_show_page.personal_qualities).to have_content(
      course_enrichment.personal_qualities,
    )
    expect(provider_courses_show_page.other_requirements).to have_content(
      course_enrichment.other_requirements,
    )
  end

  def provider
    @current_user.providers.first
  end

  def course
    provider.courses.first
  end
end
