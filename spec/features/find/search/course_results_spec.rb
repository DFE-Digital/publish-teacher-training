# frozen_string_literal: true

require 'rails_helper'

feature 'results' do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario 'when I visit the results page with no courses' do
    when_i_visit_the_find_results_page
    i_see_the_no_results_message
    and_the_search_results_should_be_tracked
  end

  scenario 'when I visit the results page with courses' do
    given_there_are_courses
    when_i_visit_the_find_results_page
    i_see_the_courses
    and_the_search_results_should_be_tracked
  end

  def when_i_visit_the_find_results_page
    find_results_page.load
  end

  def i_see_the_no_results_message
    expect(page).to have_content('You can try another search, for example by changing subjects or location')
  end

  def given_there_are_courses
    site1 = build(:site, location_name: 'site1')
    site2 = build(:site, location_name: 'site2')
    site_status1 = build(:site_status, :findable, site: site1)
    site_status2 = build(:site_status, :findable, site: site2)
    create(:course, name: 'Hello there', site_statuses: [site_status1])
    create(:course, name: 'Hello there', site_statuses: [site_status2])
  end

  def i_see_the_courses
    expect(find_results_page.courses.count).to eq(2)
    find_results_page.courses.first.then do |first_course|
      # list by provider?
      expect(first_course.course_name.text).to include('Hello there')
      expect(first_course.provider_name.text).to be_present
      expect(first_course.qualification.text).to include('QTS with PGCE')
      expect(first_course.study_mode.text).to eq('Full time')
      expect(first_course.funding_options.text).to eq('Teaching apprenticeship - with salary')
    end
  end

  def and_the_search_results_should_be_tracked
    expect(:search_results).to have_been_enqueued_as_analytics_events
  end
end
