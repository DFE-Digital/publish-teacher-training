# frozen_string_literal: true

require 'rails_helper'

feature 'Editing subject requirements section, copying content from another course' do
  scenario 'source course has gces requirements data to copy' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_with_data_i_want_to_copy

    when_i_visit_the_subject_requirements_edit_page
    and_i_select_the_other_course_from_the_copy_content_dropdown

    then_i_see_the_copied_course_data
    and_i_see_the_warning_that_changes_are_not_saved
    and_links_in_warning_match_input_ids
  end

  scenario 'copy course content options are available after validation' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_with_data_i_want_to_copy

    when_i_visit_the_subject_requirements_edit_page
    when_i_submit_without_data
    then_i_can_still_copy_content_from_another_course
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(:secondary, additional_degree_subject_requirements: nil, degree_subject_requirements: nil)
  end

  def when_i_submit_without_data
    click_on 'Update degree requirements'
  end

  def then_i_can_still_copy_content_from_another_course
    when_i_select_the_other_course_from_the_copy_content_dropdown

    then_i_see_the_copied_course_data
    and_i_see_the_warning_that_changes_are_not_saved
  end

  def and_there_is_a_course_with_data_i_want_to_copy
    @copied_course ||= create(
      :course, :secondary,
      provider: current_user.providers.first,
      additional_degree_subject_requirements: true,
      degree_subject_requirements: 'Some degree requirements'
    )
  end

  def copied_course_name_and_code
    "#{@copied_course.name} (#{@copied_course.course_code})"
  end

  def and_i_select_the_other_course_from_the_copy_content_dropdown
    select copied_course_name_and_code, from: 'Copy from'

    click_on 'Copy content'
  end
  alias_method :when_i_select_the_other_course_from_the_copy_content_dropdown, :and_i_select_the_other_course_from_the_copy_content_dropdown

  def and_i_see_the_warning_that_changes_are_not_saved
    expect(page).to have_content 'Your changes are not yet saved'
    expect(page).to have_content "We have copied these fields from #{copied_course_name_and_code}:"
    expect(page).to have_link 'Additional degree subject requirements'
    expect(page).to have_link 'Degree subject requirements'
    expect(page).to have_content 'Please check them and make your changes before saving'
  end

  def and_links_in_warning_match_input_ids
    expect((find_link 'Additional degree subject requirements')[:href].remove('#')).to eq(find_field('No')[:id])
    expect((find_link 'Degree subject requirements')[:href].remove('#')).to eq(find_field('Degree subject requirements')[:id])
  end

  def then_i_see_the_copied_course_data
    expect(find_field('Yes')).to be_checked
    expect(find_field('Degree subject requirements').value).to eq 'Some degree requirements'
  end

  def when_i_visit_the_subject_requirements_edit_page
    visit degrees_subject_requirements_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    )
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
