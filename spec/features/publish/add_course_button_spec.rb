# frozen_string_literal: true

require 'rails_helper'

feature 'Add course button', { can_edit_current_and_next_cycles: true } do
  scenario 'with no study sites on the provider in the next cycle and feature flag off' do
    given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    and_the_study_sites_feature_flag_is_not_active
    when_i_visit_the_courses_page
    then_i_should_see_the_add_course_button
  end

  scenario 'with study sites on the provider in the next cycle' do
    given_i_am_authenticated_as_a_provider_user_with_study_sites_in_the_next_cycle
    when_i_visit_the_courses_page
    then_i_should_see_the_add_course_button
  end

  scenario 'with no study sites on the provider in the current cycle' do  # This scenario can be deleted when the 2023 cycle becomes 2024
    given_i_am_authenticated_as_a_provider_user_in_the_current_cycle
    when_i_visit_the_courses_page
    then_i_should_see_the_add_course_button
  end

  def then_i_should_see_the_add_study_site_link
    expect(page).to have_link('add a study site', href: "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/study-sites")
  end

  def and_i_should_not_see_the_add_course_button
    expect(page).not_to have_link('Add course')
  end

  def then_i_should_see_the_add_course_button
    expect(page).to have_link('Add course')
  end

  def given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, :accredited_provider, :next_recruitment_cycle, sites: [build(:site)], courses: [build(:course)])
        ]
      )
    )
  end

  def given_i_am_authenticated_as_a_provider_user_in_the_current_cycle
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, sites: [build(:site)], courses: [build(:course)])
        ]
      )
    )
  end

  def given_i_am_authenticated_as_a_provider_user_with_study_sites_in_the_next_cycle
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, :accredited_provider, :next_recruitment_cycle, sites: [build(:site)], study_sites: [build(:site, :study_site)], courses: [build(:course)])
        ]
      )
    )
  end

  def and_the_study_sites_feature_flag_is_not_active
    allow(Settings.features).to receive(:study_sites).and_return(false)
  end

  def when_i_visit_the_courses_page
    publish_provider_courses_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year
    )
  end

  def provider
    @current_user.providers.first
  end
end
