# frozen_string_literal: true

require 'rails_helper'

feature 'Editing fee details section, copying content from another course' do
  scenario 'source course has fee details data to copy' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_with_data_i_want_to_copy

    when_i_visit_the_fee_details_edit_page
    and_i_select_the_other_course_from_the_copy_content_dropdown

    then_i_see_the_copied_course_data
    and_i_see_the_warning_that_changes_are_not_saved
    and_links_in_warning_match_input_ids
  end

  scenario 'copy course content options are available after validation' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_with_data_i_want_to_copy

    when_i_visit_the_fee_details_edit_page
    when_i_submit_with_too_much_data
    then_i_can_still_copy_content_from_another_course
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(:secondary, additional_degree_subject_requirements: nil, degree_subject_requirements: nil)
  end

  def when_i_submit_with_too_much_data
    fill_in 'Fees and financial support (optional)', with: 'a ' * 251
    click_on 'Update fees and financial support'
  end

  def then_i_can_still_copy_content_from_another_course
    when_i_select_the_other_course_from_the_copy_content_dropdown

    then_i_see_the_copied_course_data
    and_i_see_the_warning_that_changes_are_not_saved
  end

  def and_there_is_a_course_with_data_i_want_to_copy
    @copied_course ||= create(
      :course,
      :secondary,
      :published,
      provider: current_user.providers.first
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
    expect(page).to have_content "We have copied this field from #{copied_course_name_and_code}:"
    expect(page).to have_link 'Fees and financial support'
    expect(page).to have_content 'Please check it and make your changes before saving'
  end

  def and_links_in_warning_match_input_ids
    expect(find_link('Fees and financial support')[:href].remove('#')).to eq(find_field('Fees and financial support')[:id])
  end

  def then_i_see_the_copied_course_data
    expect(find_field('Fees and financial support (optional)').value).to eq @copied_course.enrichment_attribute('fee_details')
  end

  def when_i_visit_the_fee_details_edit_page
    visit fees_and_financial_support_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    )
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
