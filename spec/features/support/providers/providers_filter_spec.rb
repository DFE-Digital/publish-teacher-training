# frozen_string_literal: true

require 'rails_helper'

feature 'View filtered providers' do
  let(:user) { create(:user, :admin) }

  before do
    given_i_am_authenticated(user:)
    and_there_are_providers
    when_i_visit_the_support_provider_index_page
  end

  scenario 'i can view and filter the providers' do
    then_i_see_the_providers

    when_i_filter_by_provider
    then_i_see_providers_filtered_by_provider_name

    when_i_remove_the_provider_filter
    then_i_see_the_unfiltered_providers

    when_filter_by_ukprn
    then_i_see_providers_filtered_by_ukprn

    when_i_filter_by_course_code
    then_i_see_the_providers_filtered_by_course_code

    when_i_remove_the_course_code_filter
    then_i_see_the_unfiltered_providers

    when_i_filter_by_accredited_provider
    then_i_see_the_providers_filtered_by_accredited_provider

    when_i_remove_the_accredited_provider_filter
    then_i_see_the_unfiltered_providers

    when_i_filter_by_provider_code_and_course_code
    then_i_see_the_providers_filtered_by_provider_code_and_course_code

    when_i_remove_the_provider_code_and_course_code_filter
    then_i_see_the_unfiltered_providers
  end

  def then_i_see_providers_filtered_by_ukprn
    expect(page).to have_css('.qa-provider_row', count: 1)

    within first('.qa-provider_row') { expect(page).to have_text('12345678') }

    expect(page).to have_field('provider_search', with: '12345678')
  end

  def when_filter_by_ukprn
    fill_in 'Provider name, code or UKPRN', with: '12345678'
    click_link_or_button 'Apply filters'
  end

  def and_there_are_providers
    create(:provider, provider_name: 'Really big school', provider_code: 'A01', courses: [build(:course, course_code: '2VVZ')])
    create(:provider, provider_name: 'Slightly smaller school', provider_code: 'A02', ukprn: '12345678', courses: [build(:course, course_code: '2VVZ')])
    create(:provider, :accredited_provider, provider_name: 'Accredited school', provider_code: 'A03', courses: [build(:course, course_code: '2VVZ')])
  end

  def when_i_visit_the_support_provider_index_page
    support_provider_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def then_i_see_the_providers
    expect(support_provider_index_page.providers.size).to eq(3)
  end

  alias_method :then_i_see_the_unfiltered_providers, :then_i_see_the_providers

  def when_i_filter_by_accredited_provider
    check 'Accredited provider'
    click_link_or_button 'Apply filters'
  end

  def then_i_see_the_providers_filtered_by_accredited_provider
    expect(support_provider_index_page.providers.size).to eq(1)
    expect(support_provider_index_page.providers.first.text).to have_content('Accredited school A03')
  end

  def when_i_filter_by_provider
    fill_in 'Provider name, code or UKPRN', with: 'Really big school'
    click_link_or_button 'Apply filters'
  end

  def when_i_filter_by_course_code
    fill_in 'Provider name, code or UKPRN', with: ''
    fill_in 'Course code', with: '2VVZ'
    click_link_or_button 'Apply filters'
  end

  def when_i_filter_by_provider_code_and_course_code
    fill_in 'Provider name, code or UKPRN', with: 'A01'
    fill_in 'Course code', with: '2vvZ'
    click_link_or_button 'Apply filters'
  end

  def then_i_see_providers_filtered_by_provider_name
    expect(support_provider_index_page.providers.size).to eq(1)
    expect(support_provider_index_page.providers.first.text).to have_content('Really big school A01')
  end

  alias_method :then_i_see_the_providers_filtered_by_provider_code_and_course_code, :then_i_see_providers_filtered_by_provider_name

  def then_i_see_the_providers_filtered_by_course_code
    expect(support_provider_index_page.providers.size).to eq(3)
    expect(support_provider_index_page.providers[0].text).to have_content('Accredited school A03')
    expect(support_provider_index_page.providers[1].text).to have_content('Really big school A01')
    expect(support_provider_index_page.providers[2].text).to have_content('Slightly smaller school A02')
  end

  def when_i_remove_the_provider_filter
    click_link_or_button 'Remove Really big school provider search filter'
  end

  def when_i_remove_the_accredited_provider_filter
    uncheck 'Accredited provider'
    click_link_or_button 'Apply filters'
  end

  def when_i_remove_the_course_code_filter
    click_link_or_button 'Remove 2VVZ course search filter'
  end

  def when_i_remove_the_provider_code_and_course_code_filter
    click_link_or_button 'Remove A01 provider search filter'
    click_link_or_button 'Remove 2vvZ course search filter'
  end
end
