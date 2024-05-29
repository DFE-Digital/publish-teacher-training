# frozen_string_literal: true

require 'rails_helper'

feature 'Editing about this course section, copying content from another course' do
  context 'source course has "about course" data' do
    scenario 'source course has "about course" data' do
      given_i_am_authenticated_as_a_provider_user
      and_there_is_a_course_i_want_to_edit
      and_there_is_a_course_with_data_i_want_to_copy

      when_i_visit_the_about_this_course_edit_page
      and_i_select_the_other_course_from_the_copy_content_dropdown

      then_i_see_the_copied_course_data
      then_i_see_the_warning_that_changes_are_not_saved
      and_the_warning_has_a_link_to_the_about_course_input_field
    end
  end

  scenario 'source course does not have "about course" data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_without_data_i_try_to_copy

    when_i_visit_the_about_this_course_edit_page
    and_i_select_the_other_course_from_the_copy_content_dropdown
    then_i_do_not_see_copied_course_data
    and_i_do_not_see_the_warning_that_changes_are_not_saved
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def and_there_is_a_course_with_data_i_want_to_copy
    course_to_copy('About this other course')
  end

  def and_there_is_a_course_without_data_i_try_to_copy
    course_to_copy(nil)
  end

  def course_to_copy(about_course)
    @copied_course ||= create(
      :course,
      provider: current_user.providers.first,
      enrichments: [build(:course_enrichment, :published, about_course:)]
    )
  end

  def copied_course_name_and_code
    "#{@copied_course.name} (#{@copied_course.course_code})"
  end

  def and_i_select_the_other_course_from_the_copy_content_dropdown
    select copied_course_name_and_code, from: 'Copy from'

    click_on 'Copy content'
  end

  def then_i_see_the_warning_that_changes_are_not_saved
    expect(page).to have_content 'Your changes are not yet saved'
    expect(page).to have_content "We have copied this field from #{copied_course_name_and_code}."
    expect(page).to have_link 'About this course'
    expect(page).to have_content 'Please check it and make your changes before saving'
  end

  def and_i_do_not_see_the_warning_that_changes_are_not_saved
    expect(page).to have_no_content 'Your change are not yet saved'
  end

  def and_the_warning_has_a_link_to_the_about_course_input_field
    href = (find_link 'About this course')[:href]
    about_this_course_id = (find_field 'About this course')[:id]
    expect(about_this_course_id).to eq(href.remove('#'))
  end

  def then_i_see_the_copied_course_data
    expect(find_field('About this course').value).to eq @copied_course.enrichments.first.about_course
  end

  def then_i_do_not_see_copied_course_data
    expect(find_field('About this course').value).to eq @course.enrichments.first.about_course
  end

  def when_i_click_on_the_link_in_the_warning_box
    click_on 'About this course'
  end

  def then_the_focus_is_on_the_input
    about = find_field 'About this course'
    expect(about.focus?).to be true
  end

  def when_i_visit_the_about_this_course_edit_page
    visit about_this_course_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    )
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
