# frozen_string_literal: true

require 'rails_helper'

feature 'unpublished course without accredited provider', { can_edit_current_and_next_cycles: false } do
  scenario 'adding and changing an accredited provider' do
    given_i_am_authenticated_as_a_provider_user
    and_i_visit_the_course_details_page_of_a_course_without_an_accredited_provider
    and_i_click_the_add_accredited_provider_link
    and_i_create_a_new_accredited_provider
    and_i_revisit_the_course_details_page
    when_i_click_select_an_accredited_provider
    and_i_choose_the_new_accredited_provider
    then_i_should_see_the_success_message

    given_i_click_change_accredited_provider
    and_i_click_update_accredited_provider
    then_i_should_see_the_success_message
  end

  def given_i_click_change_accredited_provider
    click_link 'Change accredited provider'
  end

  def then_i_should_see_the_success_message
    expect(page).to have_text('Accredited provider updated')
  end

  def and_i_click_update_accredited_provider
    click_button 'Update accredited provider'
  end

  def and_i_choose_the_new_accredited_provider
    choose @accredited_provider.provider_name
    and_i_click_update_accredited_provider
  end

  def when_i_click_select_an_accredited_provider
    click_link 'Select an accredited provider'
  end

  def and_i_create_a_new_accredited_provider
    and_there_is_an_accredited_provider_in_the_database
    and_i_click_add_accredited_provider_link
    and_i_search_for_an_accredited_provider_with_a_valid_query
    and_i_select_the_provider
    and_i_input_some_information
    and_i_click_add_accredited_provider_button
  end

  def and_i_select_the_provider
    choose @accredited_provider.provider_name
    click_continue
  end

  def and_i_input_some_information
    fill_in 'About the accredited provider', with: 'This is a description'
    click_continue
  end

  def and_there_is_an_accredited_provider_in_the_database
    @accredited_provider = create(:provider, :accredited_provider, provider_name: 'UCL')
  end

  def and_i_search_for_an_accredited_provider_with_a_valid_query
    fill_in form_title, with: @accredited_provider.provider_name
    click_continue
  end

  def click_continue
    click_button 'Continue'
  end

  def form_title
    'Enter a provider name, UKPRN or postcode'
  end

  def and_i_click_the_add_accredited_provider_link
    click_link 'Add at least one accredited provider'
  end

  def and_i_click_add_accredited_provider_link
    click_link 'Add accredited provider'
  end

  def and_i_click_add_accredited_provider_button
    click_button 'Add accredited provider'
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, sites: [build(:site)], courses: [build(:course)])
        ]
      )
    )
  end

  def and_i_visit_the_course_details_page_of_a_course_without_an_accredited_provider
    publish_provider_courses_details_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code
    )
  end

  alias_method :and_i_revisit_the_course_details_page, :and_i_visit_the_course_details_page_of_a_course_without_an_accredited_provider

  def provider
    @current_user.providers.first
  end

  def course
    provider.courses.first
  end
end
