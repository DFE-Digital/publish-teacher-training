# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Primary subjects quick link', service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  context 'when filter by subjects' do
    before do
      given_there_are_courses_with_primary_subjects
      when_i_visit_the_find_homepage
    end

    scenario 'filter by a primary course' do
      click_link_or_button 'Browse primary courses'
      when_i_select_primary_with_english
      then_i_see_only_see_primary_with_english_courses
    end

    scenario 'filter all primary courses' do
      click_link_or_button 'Browse primary courses'
      when_i_select_all_primary_courses
      then_i_see_all_primary_courses
    end

    scenario 'errors when no courses are selected' do
      click_link_or_button 'Browse primary courses'
      click_link_or_button 'Find primary courses'
      then_i_see_errors
    end
  end

  def given_there_are_courses_with_primary_subjects
    create(:course, :open, :with_full_time_sites, :primary, name: 'Primary', course_code: 'S872', subjects: [find_or_create(:primary_subject, :primary)])
    create(:course, :open, :with_full_time_sites, :primary, name: 'Primary with english', course_code: 'K592', subjects: [find_or_create(:primary_subject, :primary_with_english)])
    create(:course, :open, :with_full_time_sites, :primary, name: 'Primary with mathematics', course_code: 'L364', subjects: [find_or_create(:primary_subject, :primary_with_mathematics)])
    create(:course, :open, :with_full_time_sites, :primary, name: 'Primary with science', course_code: '4RTU', subjects: [find_or_create(:primary_subject, :primary_with_science)])
  end

  def when_i_visit_the_find_homepage
    visit find_path
  end

  def when_i_select_primary_with_english
    check 'Primary with English'
    click_link_or_button 'Find primary courses'
  end

  def when_i_select_all_primary_courses
    check 'Primary'
    check 'Primary with English'
    check 'Primary with geography and history'
    check 'Primary with mathematics'
    check 'Primary with modern languages'
    check 'Primary with physical education'
    check 'Primary with science'
    click_link_or_button 'Find primary courses'
  end

  def then_i_see_only_see_primary_with_english_courses
    expect(page).to have_content('1 course found')
  end

  def then_i_see_all_primary_courses
    expect(page).to have_content('4 courses found')
  end

  def then_i_see_errors
    expect(page).to have_content('Select at least one type of primary course')
  end
end
