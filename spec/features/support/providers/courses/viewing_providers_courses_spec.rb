# frozen_string_literal: true

require 'rails_helper'

feature 'Viewing a providers courses' do
  scenario 'Provider is discarded' do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_discarded_provider_with_courses
    when_i_visit_the_support_discarded_provider_courses_index_page
    then_i_am_redirected_to_the_providers_page
  end

  scenario 'viewing course status tags' do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_provider_with_courses
    when_i_visit_the_support_provider_courses_index_page
    then_i_should_see_the_open_status
  end

  private

  def then_i_should_see_the_open_status
    within('td.govuk-table__cell.status') do
      expect(page).to have_css('strong.govuk-tag.govuk-tag--turquoise', text: 'Open')
    end
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def discarded_provider
    @provider ||= create(:provider, id: 1, courses: [build(:course)], discarded_at: Time.zone.now)
  end

  def provider
    @provider ||= create(:provider, id: 2, courses: [build(:course, :published, :open)])
  end

  def and_there_is_a_provider_with_courses
    provider
  end

  def and_there_is_a_discarded_provider_with_courses
    discarded_provider
  end

  def when_i_visit_the_support_provider_courses_index_page
    support_provider_courses_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: 2)
  end

  def when_i_visit_the_support_discarded_provider_courses_index_page
    support_provider_courses_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: 1)
  end

  def then_i_am_redirected_to_the_providers_page
    expect(support_provider_index_page).to be_displayed
  end
end
