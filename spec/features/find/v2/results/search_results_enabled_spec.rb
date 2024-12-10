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

  scenario 'when I filter by study type' do
    given_there_are_courses_containing_all_study_types
    when_i_visit_the_find_results_page
    and_i_filter_only_by_part_time_courses
    then_i_see_only_part_time_courses
    and_the_part_time_filter_is_checked
    when_i_filter_only_by_full_time_courses
    then_i_see_only_full_time_courses
    and_the_full_time_filter_is_checked
    when_i_filter_by_part_time_and_full_time_courses
    then_i_see_all_courses_containing_all_study_types
    and_the_part_time_filter_is_checked
    and_the_full_time_filter_is_checked
  end

  scenario 'when I filter by applications open' do
    given_there_are_courses_open_for_applications
    and_there_are_courses_that_are_closed_for_applications
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_open_for_applications
    then_i_see_only_courses_that_are_open_for_applications
    and_the_open_for_application_filter_is_checked
  end

  scenario 'when I filter by special educational needs' do
    given_there_are_courses_with_special_education_needs
    and_there_are_courses_that_with_no_special_education_needs
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_with_special_education_needs
    then_i_see_only_courses_with_special_education_needs
    and_the_special_education_needs_filter_is_checked
  end

  def given_i_am_authenticated
    page.driver.browser.authorize 'admin', 'password'
  end

  def given_there_are_courses_that_sponsor_visa
    create(:course, :with_full_time_sites, :can_sponsor_skilled_worker_visa, name: 'Biology', course_code: 'S872')
    create(:course, :with_full_time_sites, :can_sponsor_student_visa, name: 'Chemistry', course_code: 'K592')
    create(:course, :with_full_time_sites, :can_sponsor_student_visa, :can_sponsor_skilled_worker_visa, name: 'Computing', course_code: 'L364')
  end

  def given_there_are_courses_containing_all_study_types
    create(:course, :with_full_time_sites, study_mode: 'full_time', name: 'Biology', course_code: 'S872')
    create(:course, :with_part_time_sites, study_mode: 'part_time', name: 'Chemistry', course_code: 'K592')
    create(:course, :with_full_time_or_part_time_sites, study_mode: 'full_time_or_part_time', name: 'Computing', course_code: 'L364')
  end

  def given_there_are_courses_open_for_applications
    create(:course, :with_full_time_sites, :open, name: 'Biology', course_code: 'S872')
    create(:course, :with_full_time_sites, :open, name: 'Chemistry', course_code: 'K592')
    create(:course, :with_full_time_sites, :open, name: 'Computing', course_code: 'L364')
  end

  def and_there_are_courses_that_are_closed_for_applications
    create(:course, :with_full_time_sites, :closed, name: 'Dance', course_code: 'C115')
    create(:course, :with_full_time_sites, :closed, name: 'Physics', course_code: '3CXN')
  end

  def given_there_are_courses_with_special_education_needs
    create(:course, :with_full_time_sites, :with_special_education_needs, name: 'Biology SEND', course_code: 'S872')
    create(:course, :with_full_time_sites, :with_special_education_needs, name: 'Chemistry SEND', course_code: 'K592')
    create(:course, :with_full_time_sites, :with_special_education_needs, name: 'Computing SEND', course_code: 'L364')
  end

  def and_there_are_courses_that_with_no_special_education_needs
    create(:course, :with_full_time_sites, is_send: false, can_sponsor_student_visa: false, name: 'Dance', course_code: 'C115')
    create(:course, :with_full_time_sites, is_send: false, name: 'Physics', course_code: '3CXN')
  end

  def and_there_are_courses_that_do_not_sponsor_visa
    create(:course, :with_full_time_sites, can_sponsor_skilled_worker_visa: false, can_sponsor_student_visa: false, name: 'Dance', course_code: 'C115')
  end

  def when_i_visit_the_find_results_page
    visit find_v2_results_path
  end

  def and_i_filter_by_courses_that_sponsor_visa
    check 'Only show courses with visa sponsorship'
    and_i_apply_the_filters
  end

  def and_i_filter_only_by_part_time_courses
    uncheck 'Full time (12 months)'
    check 'Part time (18 to 24 months)'
    and_i_apply_the_filters
  end

  def when_i_filter_only_by_full_time_courses
    uncheck 'Part time (18 to 24 months)'
    check 'Full time (12 months)'
    and_i_apply_the_filters
  end

  def when_i_filter_by_part_time_and_full_time_courses
    check 'Part time (18 to 24 months)'
    check 'Full time (12 months)'
    and_i_apply_the_filters
  end

  def and_i_filter_by_courses_open_for_applications
    check 'Only show courses open for applications'
    and_i_apply_the_filters
  end

  def and_i_filter_by_courses_with_special_education_needs
    check 'Only show courses with a SEND specialism'
    and_i_apply_the_filters
  end

  def then_i_see_only_courses_that_sponsor_visa
    expect(page).to have_content('Biology (S872')
    expect(page).to have_content('Chemistry (K592)')
    expect(page).to have_content('Computing (L364)')
    expect(page).to have_no_content('Dance (C115)')
  end

  def then_i_see_only_part_time_courses
    expect(page).to have_content('Chemistry (K592)')
    expect(page).to have_content('Computing (L364)')
    expect(page).to have_no_content('Biology (S872)')
  end

  def and_the_part_time_filter_is_checked
    expect(page).to have_checked_field('Part time (18 to 24 months)')
  end

  def then_i_see_only_full_time_courses
    expect(page).to have_content('Biology (S872)')
    expect(page).to have_content('Computing (L364)')
    expect(page).to have_no_content('Chemistry (K592)')
  end

  def and_the_full_time_filter_is_checked
    expect(page).to have_checked_field('Full time (12 months)')
  end

  def then_i_see_all_courses_containing_all_study_types
    expect(page).to have_content('Biology (S872)')
    expect(page).to have_content('Computing (L364)')
    expect(page).to have_content('Chemistry (K592)')
  end

  def then_i_see_only_courses_with_special_education_needs
    expect(page).to have_content('Biology SEND (S872')
    expect(page).to have_content('Chemistry SEND (K592)')
    expect(page).to have_content('Computing SEND (L364)')
    expect(page).to have_no_content('Dance (C115)')
    expect(page).to have_no_content('Physics (3CXN)')
  end

  def then_i_see_only_courses_that_are_open_for_applications
    expect(page).to have_content('Biology (S872')
    expect(page).to have_content('Chemistry (K592)')
    expect(page).to have_content('Computing (L364)')
    expect(page).to have_no_content('Dance (C115)')
    expect(page).to have_no_content('Physics (3CXN)')
  end

  def and_the_visa_sponsorship_filter_is_checked
    expect(page).to have_checked_field('Only show courses with visa sponsorship')
  end

  def and_the_open_for_application_filter_is_checked
    expect(page).to have_checked_field('Only show courses open for applications')
  end

  def and_the_special_education_needs_filter_is_checked
    expect(page).to have_checked_field('Only show courses with a SEND specialism')
  end

  def and_i_apply_the_filters
    click_link_or_button 'Apply filters'
  end
end
