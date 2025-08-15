# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe "Publish - Select all schools", :js, type: :system do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
  end

  scenario "select all schools and update" do
    when_i_select_all_schools
    and_i_submit
    then_i_should_see_the_success_message
    and_all_schools_should_be_assigned_to_the_course
  end

  scenario "unselect all schools and update" do
    when_i_select_all_schools
    and_i_unselect_all_schools
    and_i_submit
    then_i_should_see_the_no_schools_validation_error
  end

  context "when many schools" do
    around do |example|
      Sidekiq::Testing.inline! do
        example.run
      end
    end

    scenario "enqueue when many schools to update" do
      given_there_are_many_schools
      when_i_visit_the_publish_course_school_edit_page
      when_i_select_all_schools
      and_i_submit
      then_i_should_see_the_enqueued_success_message
      and_many_schools_should_be_attached_to_courses
    end
  end

  def given_i_am_authenticated_as_a_provider_user
    @provider = build(
      :provider,
      sites: [
        build(:site, location_name: "Site 1"),
        build(:site, location_name: "Site 2"),
        build(:site, location_name: "Site 3"),
      ],
    )
    @user = create(
      :user,
      providers: [provider],
    )
    given_i_am_authenticated(user: @user)
    @provider.reload
  end

  def given_there_are_many_schools
    @schools = create_list(:site, 30, provider: @provider)
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(sites: [])
  end

  def when_i_visit_the_publish_course_school_edit_page
    publish_course_school_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
  end

  def when_i_select_all_schools
    check "Select all schools"
  end

  def and_i_unselect_all_schools
    uncheck "Select all schools"
  end

  def and_i_submit
    click_link_or_button "Update placement schools"
  end

  def then_i_should_see_the_success_message
    expect(page).to have_content("Schools updated")
  end

  def and_all_schools_should_be_assigned_to_the_course
    expect(course.reload.sites.map(&:location_name))
      .to contain_exactly("Site 1", "Site 2", "Site 3")
  end

  def and_many_schools_should_be_attached_to_courses
    expect(course.reload.sites.map(&:location_name))
      .to match_array(["Site 1", "Site 2", "Site 3", @schools.map(&:location_name)].flatten)
  end

  def then_i_should_see_the_no_schools_validation_error
    expect(page).to have_content("Select at least one school")
  end

  def then_i_should_see_the_enqueued_success_message
    expect(page).to have_content(
      "We are now processing your added schools, please wait a minute until all your schools are added",
    )
  end

  def given_a_course_exists(sites: [])
    @course = create(:course, provider:, sites:)
  end

  attr_reader :course

  attr_reader :provider
end
