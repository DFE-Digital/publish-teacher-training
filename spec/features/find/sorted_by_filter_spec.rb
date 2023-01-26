# frozen_string_literal: true

require "rails_helper"

feature "sorted by" do
  before do
    given_there_are_courses
    and_i_visit_the_results_page
  end

  scenario "when I search the default sorting is by courses (A-Z)" do
    then_the_results_should_be_ordered_by_course_name_ascending_then_provider_name_then_course_code
  end

  scenario "sorting results page by courses (Z-A)" do
    given_that_i_select_the_option("Course name (Z-A)")
    when_i_click_sort
    then_the_results_should_be_ordered_by_course_name_descending_then_provider_name_then_course_code
  end

  scenario "when I sort the results page by provider (A-Z)" do
    given_that_i_select_the_option("Training provider (A-Z)")
    when_i_click_sort
    then_the_results_should_be_ordered_by_provider_name_ascending_then_course_name_then_course_code
  end

  scenario "when I sort the results page by provider (Z-A)" do
    given_that_i_select_the_option("Training provider (Z-A)")
    when_i_click_sort
    then_the_results_should_be_ordered_by_provider_name_descending_then_course_name_then_course_code
  end

  def given_there_are_courses
    site1 = create(:site, location_name: "site1")
    site2 = create(:site, location_name: "site2")
    site3 = create(:site, location_name: "site3")
    site4 = create(:site, location_name: "site4")
    site_status1 = create(:site_status, :findable, site: site1)
    site_status2 = create(:site_status, :findable, site: site2)
    site_status3 = create(:site_status, :findable, site: site3)
    site_status4 = create(:site_status, :findable, site: site4)
    provider1 = create(:provider, provider_name: "Arandomprovider")
    provider2 = create(:provider, provider_name: "Brandomprovider")
    create(:course, name: "Brandomcoursename", course_code: "AAAA", site_statuses: [site_status2], provider: provider1)
    create(:course, name: "Arandomcoursename", course_code: "AAAC", site_statuses: [site_status4], provider: provider1)
    create(:course, name: "Arandomcoursename", course_code: "AAAB", site_statuses: [site_status3], provider: provider2)
    create(:course, name: "Arandomcoursename", course_code: "AAAD", site_statuses: [site_status1], provider: provider1)
  end

  def and_i_visit_the_results_page
    results_page.load
  end

  def then_the_results_should_be_ordered_by_course_name_ascending_then_provider_name_then_course_code
    results_page.courses.first.then { |first_course| expect(first_course.course_name.text).to include("AAAC") }
    results_page.courses.second.then { |second_course| expect(second_course.course_name.text).to include("AAAD") }
    results_page.courses.third.then { |third_course| expect(third_course.course_name.text).to include("AAAB") }
    results_page.courses.fourth.then { |fourth_course| expect(fourth_course.course_name.text).to include("AAAA") }
  end

  def then_the_results_should_be_ordered_by_course_name_descending_then_provider_name_then_course_code
    results_page.courses.first.then { |first_course| expect(first_course.course_name.text).to include("AAAA") }
    results_page.courses.second.then { |second_course| expect(second_course.course_name.text).to include("AAAC") }
    results_page.courses.third.then { |third_course| expect(third_course.course_name.text).to include("AAAD") }
    results_page.courses.fourth.then { |fourth_course| expect(fourth_course.course_name.text).to include("AAAB") }
  end

  def then_the_results_should_be_ordered_by_provider_name_ascending_then_course_name_then_course_code
    results_page.courses.first.then { |first_course| expect(first_course.course_name.text).to include("AAAC") }
    results_page.courses.second.then { |second_course| expect(second_course.course_name.text).to include("AAAD") }
    results_page.courses.third.then { |third_course| expect(third_course.course_name.text).to include("AAAA") }
    results_page.courses.fourth.then { |fourth_course| expect(fourth_course.course_name.text).to include("AAAB") }
  end

  def then_the_results_should_be_ordered_by_provider_name_descending_then_course_name_then_course_code
    results_page.courses.first.then { |first_course| expect(first_course.course_name.text).to include("AAAB") }
    results_page.courses.second.then { |second_course| expect(second_course.course_name.text).to include("AAAC") }
    results_page.courses.third.then { |third_course| expect(third_course.course_name.text).to include("AAAD") }
    results_page.courses.fourth.then { |fourth_course| expect(fourth_course.course_name.text).to include("AAAA") }
  end

  def given_that_i_select_the_option(selected_option)
    select(selected_option, from: "sortby")
  end

  def when_i_click_sort
    click_button "Sort"
  end
end
