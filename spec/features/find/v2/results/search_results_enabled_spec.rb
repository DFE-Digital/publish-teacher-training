# frozen_string_literal: true

require 'rails_helper'

feature 'V2 results - enabled' do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Settings.features).to receive_messages(v2_results: true)
    given_i_am_authenticated
  end

  scenario 'when I filter by visa sponsorship' do
    given_there_are_courses_that_sponsor_visa
    and_there_are_courses_that_do_not_sponsor_visa
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_that_sponsor_visa
    then_i_see_only_courses_that_sponsor_visa
    and_the_visa_sponsorship_filter_is_checked
  end

  def given_i_am_authenticated
    page.driver.browser.authorize 'admin', 'password'
  end

  def given_there_are_courses_that_sponsor_visa
    create(:course, :with_full_time_sites, :can_sponsor_skilled_worker_visa, name: 'Biology', course_code: 'S872')
    create(:course, :with_full_time_sites, :can_sponsor_student_visa, name: 'Chemistry', course_code: 'K592')
    create(:course, :with_full_time_sites, :can_sponsor_student_visa, :can_sponsor_skilled_worker_visa, name: 'Computing', course_code: 'L364')
  end

  def and_there_are_courses_that_do_not_sponsor_visa
    create(:course, :with_full_time_sites, can_sponsor_skilled_worker_visa: false, can_sponsor_student_visa: false, name: 'Dance', course_code: 'C115')
  end

  def when_i_visit_the_find_results_page
    visit find_v2_results_path
  end

  def and_i_filter_by_courses_that_sponsor_visa
    check 'Only show courses with visa sponsorship'
    click_link_or_button 'Apply filters'
  end

  def then_i_see_only_courses_that_sponsor_visa
    expect(page).to have_content('Biology (S872')
    expect(page).to have_content('Chemistry (K592)')
    expect(page).to have_content('Computing (L364)')
    expect(page).to have_no_content('Dance (C115)')
  end

  def and_the_visa_sponsorship_filter_is_checked
    expect(page).to have_checked_field('Only show courses with visa sponsorship')
  end
end
