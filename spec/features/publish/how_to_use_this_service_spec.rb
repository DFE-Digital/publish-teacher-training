# frozen_string_literal: true

require 'rails_helper'

feature 'Guidance pages', :with_publish_constraint do
  scenario 'Navigating through how to use this service pages' do
    given_i_visit_the_root_path
    when_i_click_how_to_use_this_service
    then_i_should_see_the_h1_how_to_use_this_service

    given_i_click_add_an_organisation
    then_i_should_see_the_h1_add_an_organisation

    given_i_click_on_the_how_to_use_this_service_breadcrumb
    when_i_click_on_add_and_remove_users
    then_i_should_see_the_h1_add_and_remove_users

    given_i_click_on_the_how_to_use_this_service_breadcrumb
    when_i_click_on_change_an_accredited_provider_relationship
    then_i_should_see_the_h1_change_an_accredited_provider_relationship

    given_i_click_on_the_how_to_use_this_service_breadcrumb
    when_i_click_on_roll_over_courses_to_a_new_recruitment_cycle
    then_i_should_see_the_h1_roll_over_courses_to_a_new_recruitment_cycle

    given_i_click_on_the_how_to_use_this_service_breadcrumb
    when_click_on_help_writing_course_descriptions
    then_i_should_see_the_h1_help_writing_course_descriptions

    given_i_click_on_the_how_to_use_this_service_breadcrumb
    when_i_click_on_course_summary_examples
    then_i_should_see_the_h1_course_summary_examples
  end

  def given_i_visit_the_root_path
    visit root_path
  end

  def when_i_click_how_to_use_this_service
    click_link_or_button 'How to use this service'
  end

  def then_i_should_see_the_h1_how_to_use_this_service
    expect(page).to have_css('h1', text: 'How to use this service')
  end

  def given_i_click_add_an_organisation
    click_link_or_button 'Add an organisation'
  end

  def then_i_should_see_the_h1_add_an_organisation
    expect(page).to have_css('h1', text: 'Add an organisation')
  end

  def given_i_click_on_the_how_to_use_this_service_breadcrumb
    click_link_or_button 'How to use this service', match: :first
  end

  def when_i_click_on_add_and_remove_users
    click_link_or_button 'Add and remove users'
  end

  def then_i_should_see_the_h1_add_and_remove_users
    expect(page).to have_css('h1', text: 'Add and remove users')
  end

  def when_i_click_on_change_an_accredited_provider_relationship
    click_link_or_button 'Change an accredited provider relationship'
  end

  def then_i_should_see_the_h1_change_an_accredited_provider_relationship
    expect(page).to have_css('h1', text: 'Change an accredited provider relationship')
  end

  def when_i_click_on_roll_over_courses_to_a_new_recruitment_cycle
    click_link_or_button 'Roll over courses to a new recruitment cycle'
  end

  def then_i_should_see_the_h1_roll_over_courses_to_a_new_recruitment_cycle
    expect(page).to have_css('h1', text: 'Roll over courses to a new recruitment cycle')
  end

  def when_click_on_help_writing_course_descriptions
    click_link_or_button 'Help writing course descriptions'
  end

  def then_i_should_see_the_h1_help_writing_course_descriptions
    expect(page).to have_css('h1', text: 'Help writing course descriptions')
  end

  def when_i_click_on_course_summary_examples
    click_link_or_button 'Course summary examples'
  end

  def then_i_should_see_the_h1_course_summary_examples
    expect(page).to have_css('h1', text: 'Course summary examples')
  end
end
