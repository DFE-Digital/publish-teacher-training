# frozen_string_literal: true

require "rails_helper"

feature "Editing interview process section, copying content from another course" do
  context 'source course has "interview process" data' do
    scenario 'source course has "about course" data' do
      given_i_am_authenticated_as_a_provider_user
      and_there_is_a_course_i_want_to_edit
      and_there_is_a_course_with_data_i_want_to_copy

      when_i_visit_the_interview_process_edit_page
      and_i_select_the_other_course_from_the_copy_content_dropdown

      then_i_see_the_copied_course_data
      and_i_see_the_warning_that_changes_are_not_saved
      and_the_warning_has_a_link_to_the_interview_process_input_field
    end
  end

  scenario 'source course does not have "interview process" data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_without_data_i_try_to_copy

    when_i_visit_the_interview_process_edit_page
    and_i_select_the_other_course_from_the_copy_content_dropdown
    then_i_do_not_see_copied_course_data
    and_i_do_not_see_the_warning_that_changes_are_not_saved
  end

  scenario "copy course content options are available after validation" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_with_data_i_want_to_copy

    when_i_visit_the_interview_process_edit_page
    when_i_submit_with_too_many_words
    then_i_can_still_copy_content_from_another_course
  end

private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def and_there_is_a_course_with_data_i_want_to_copy
    course_to_copy("About this other course")
  end

  def and_there_is_a_course_without_data_i_try_to_copy
    course_to_copy(nil)
  end

  def when_i_submit_with_too_many_words
    fill_in "Interview process", with: Faker::Lorem.sentence(word_count: 251)
    click_on "Update interview process"
  end

  def then_i_can_still_copy_content_from_another_course
    when_i_select_the_other_course_from_the_copy_content_dropdown

    then_i_see_the_copied_course_data
    and_i_see_the_warning_that_changes_are_not_saved
  end

  def course_to_copy(interview_process)
    @copied_course ||= create(
      :course,
      provider: current_user.providers.first,
      enrichments: [build(:course_enrichment, :published, interview_process:)],
    )
  end

  def copied_course_name_and_code
    "#{@copied_course.name} (#{@copied_course.course_code})"
  end

  def and_i_select_the_other_course_from_the_copy_content_dropdown
    select copied_course_name_and_code, from: "Copy from"

    click_on "Copy content"
  end
  alias_method :when_i_select_the_other_course_from_the_copy_content_dropdown, :and_i_select_the_other_course_from_the_copy_content_dropdown

  def and_i_see_the_warning_that_changes_are_not_saved
    expect(page).to have_content "Your changes are not yet saved"
    expect(page).to have_content "We have copied this field from #{copied_course_name_and_code}:"
    expect(page).to have_link "Interview process"
    expect(page).to have_content "Please check it and make your changes before saving"
  end

  def and_i_do_not_see_the_warning_that_changes_are_not_saved
    expect(page).to have_no_content "Your change are not yet saved"
  end

  def and_the_warning_has_a_link_to_the_interview_process_input_field
    href = find_link("Interview process")[:href]
    interview_process_id = (find_field "Interview process")[:id]
    expect(interview_process_id).to eq(href.remove("#"))
  end

  def then_i_see_the_copied_course_data
    expect(find_field("Interview process").value).to eq @copied_course.enrichments.first.interview_process
  end

  def then_i_do_not_see_copied_course_data
    expect(find_field("Interview process").value).to eq @course.enrichments.first.interview_process
  end

  def when_i_click_on_the_link_in_the_warning_box
    click_on "Interview process"
  end

  def when_i_visit_the_interview_process_edit_page
    visit interview_process_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code,
    )
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
