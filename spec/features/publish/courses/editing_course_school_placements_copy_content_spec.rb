# frozen_string_literal: true

require 'rails_helper'

feature 'Editing school placements section, copying content from another course' do
  scenario 'source course has "about course" data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_with_data_i_want_to_copy

    when_i_visit_the_school_placements_edit_page
    and_i_select_the_other_course_from_the_copy_content_dropdown

    then_i_see_the_copied_course_data
    and_i_see_the_warning_that_changes_are_not_saved
    and_the_warning_has_a_link_to_the_school_placements_input_field
  end

  scenario 'source course does not have "about course" data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_without_data_i_try_to_copy

    when_i_visit_the_school_placements_edit_page
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

  def course_to_copy(how_school_placements_work)
    @copied_course ||= create(
      :course,
      provider: current_user.providers.first,
      enrichments: [build(:course_enrichment, :published, how_school_placements_work:)]
    )
  end

  def copied_course_name_and_code
    "#{@copied_course.name} (#{@copied_course.course_code})"
  end

  def and_i_select_the_other_course_from_the_copy_content_dropdown
    select copied_course_name_and_code, from: 'Copy from'

    click_on 'Copy content'
  end

  def and_i_see_the_warning_that_changes_are_not_saved
    expect(page).to have_content 'Your changes are not yet saved'
    expect(page).to have_content "We have copied this field from #{copied_course_name_and_code}."
    expect(page).to have_link 'How school placements work'
    expect(page).to have_content 'Please check it and make your changes before saving'
  end

  def and_i_do_not_see_the_warning_that_changes_are_not_saved
    expect(page).to have_no_content 'Your change are not yet saved'
  end

  def and_the_warning_has_a_link_to_the_school_placements_input_field
    href = find_link('How school placements work')[:href]
    school_placements_id = (find_field 'How school placements work')[:id]
    expect(school_placements_id).to eq(href.remove('#'))
  end

  def then_i_see_the_copied_course_data
    expect(find_field('How school placements work').value).to eq @copied_course.enrichments.first.how_school_placements_work
  end

  def then_i_do_not_see_copied_course_data
    expect(find_field('How school placements work').value).to eq @course.enrichments.first.how_school_placements_work
  end

  def then_the_focus_is_on_the_input
    about = find_field 'Interview process'
    expect(about.focus?).to be true
  end

  def when_i_visit_the_school_placements_edit_page
    visit school_placements_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    )
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
