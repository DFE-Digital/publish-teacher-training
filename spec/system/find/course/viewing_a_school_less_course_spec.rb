# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Searching for and viewing a salaried course published without an employing school", service: :find do
  include Rails.application.routes.url_helpers

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    FeatureFlag.activate(:course_publishing_uses_new_school_model)
    given_there_is_a_findable_school_less_salaried_course
  end

  scenario "the course appears in the results with the no-employing-schools text" do
    when_i_visit_the_results_page
    then_i_see_the_course_listed
    and_i_see_no_employing_schools_listed
  end

  scenario "the course page shows the no-employing-schools text and no placements link" do
    when_i_visit_the_course_page
    then_i_see_the_course_page
    and_i_see_no_employing_schools_listed
    and_i_do_not_see_a_school_placements_link
  end

  def given_there_is_a_findable_school_less_salaried_course
    @provider = create(:provider, provider_name: "Salaried Provider")
    @course = create(
      :course,
      :with_salary,
      :published,
      name: "Chemistry",
      course_code: "K592",
      application_status: "open",
      publish_without_schools_allowed: true,
      provider: @provider,
    )
  end

  def when_i_visit_the_results_page
    visit find_results_path
  end

  def when_i_visit_the_course_page
    visit find_course_path(provider_code: @provider.provider_code, course_code: @course.course_code)
  end

  def then_i_see_the_course_listed
    expect(page).to have_content(@course.name_and_code)
  end

  def then_i_see_the_course_page
    expect(page).to have_content("#{@course.name} (#{@course.course_code})")
  end

  def and_i_see_no_employing_schools_listed
    expect(page).to have_content("No employing schools listed")
    expect(page).to have_no_content("Search by city, town or postcode to find the nearest potential employing school")
  end

  def and_i_do_not_see_a_school_placements_link
    expect(page).to have_no_link("View list of school placements")
  end
end
