# frozen_string_literal: true

require "rails_helper"

feature "Managing a provider's courses" do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_courses_page
  end

  scenario "i can view a provider's courses" do
    then_i_should_see_a_list_of_courses
  end

  scenario "i can view a single provider's course" do
    and_i_click_on_a_course
    then_i_see_the_course
  end

  scenario "i can view new course level page" do
    and_i_click_on_add_course
    then_i_see_the_new_course_level_page
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, sites: [build(:site)], courses: [build(:course)]),
        ],
      ),
    )
  end

  def when_i_visit_the_courses_page
    publish_provider_courses_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def then_i_should_see_a_list_of_courses
    expect(publish_provider_courses_index_page.courses.size).to eq(1)

    expect(publish_provider_courses_index_page.courses.first.name).to have_text(course.name)
  end

  def and_i_click_on_a_course
    publish_provider_courses_index_page.courses.first.link.click
  end

  def then_i_see_the_course
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}")
  end

  def and_i_click_on_add_course
    publish_provider_courses_index_page.add_course.click
  end

  def then_i_see_the_new_course_level_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/level/new")
  end

  def provider
    @current_user.providers.first
  end

  def course
    @course ||= provider.courses.first
  end
end
