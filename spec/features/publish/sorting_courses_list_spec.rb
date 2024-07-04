# frozen_string_literal: true

require 'rails_helper'

feature 'Sorting courses list', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_courses_page
  end

  scenario 'i can sort alphabetically' do
    when_i_click_on_the_course_a_z_heading
    then_i_see_courses_ordered_alphabetically_ascending

    when_i_click_on_the_course_z_a_heading
    then_i_see_courses_ordered_alphabetically_descending
  end

  scenario 'i can sort by status' do
    when_i_click_on_the_status_heading
    then_i_see_courses_ordered_by_status

    when_i_click_on_the_status_heading
    then_i_see_courses_ordered_by_status_in_reverse
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, :accredited_provider, sites: [build(:site)], courses: [build(:course, :open, :published, name: 'A'), build(:course, :closed, :published, name: 'B'), build(:course, :withdrawn, name: 'C')])
        ]
      )
    )
  end

  def when_i_visit_the_courses_page
    publish_provider_courses_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year
    )
  end

  def provider
    @current_user.providers.first
  end

  def course
    @course ||= provider.courses.first
  end

  def when_i_click_on_the_course_a_z_heading
    click_on('Course (a-z)')
  end

  def when_i_click_on_the_course_z_a_heading
    click_on('Course (z-a)')
  end

  def when_i_click_on_the_status_heading
    click_on('Status')
  end

  def then_i_see_courses_ordered_alphabetically_ascending
    expect(page).to have_css('tbody.govuk-table__body tr.govuk-table__row:nth-child(1) a', text: 'A')
    expect(page).to have_css('tbody.govuk-table__body tr.govuk-table__row:nth-child(2) a', text: 'B')
    expect(page).to have_css('tbody.govuk-table__body tr.govuk-table__row:nth-child(3) a', text: 'C')
  end

  def then_i_see_courses_ordered_alphabetically_descending
    expect(page).to have_css('tbody.govuk-table__body tr.govuk-table__row:nth-child(1) a', text: 'C')
    expect(page).to have_css('tbody.govuk-table__body tr.govuk-table__row:nth-child(2) a', text: 'B')
    expect(page).to have_css('tbody.govuk-table__body tr.govuk-table__row:nth-child(3) a', text: 'A')
  end

  def then_i_see_courses_ordered_by_status
    expect(page).to have_css('tbody.govuk-table__body tr:nth-child(1) .govuk-tag--turquoise', text: 'Open')
    expect(page).to have_css('tbody.govuk-table__body tr:nth-child(2) .govuk-tag--purple', text: 'Closed')
    expect(page).to have_css('tbody.govuk-table__body tr:nth-child(3) .govuk-tag--red', text: 'Withdrawn')
  end

  def then_i_see_courses_ordered_by_status_in_reverse
    expect(page).to have_css('tbody.govuk-table__body tr:nth-child(1) .govuk-tag--red', text: 'Withdrawn')
    expect(page).to have_css('tbody.govuk-table__body tr:nth-child(2) .govuk-tag--purple', text: 'Closed')
    expect(page).to have_css('tbody.govuk-table__body tr:nth-child(3) .govuk-tag--turquoise', text: 'Open')
  end
end
