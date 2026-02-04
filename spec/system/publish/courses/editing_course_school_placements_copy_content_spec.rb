# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing school placements section, copying content from another course" do
  scenario "source course has both placement_school_activities and support_and_mentorship fields" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_with_both_school_placement_fields_i_want_to_copy

    when_i_visit_the_school_placement_edit_page
    and_i_select_the_other_course_from_the_copy_content_dropdown

    then_i_see_plural_copy_warning_for_school_placements
  end

  scenario 'source course has "about course" data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_with_data_i_want_to_copy

    when_i_visit_the_school_placement_edit_page
    and_i_select_the_other_course_from_the_copy_content_dropdown

    then_i_see_the_copied_course_data
    and_i_see_the_warning_that_changes_are_not_saved
    and_the_warning_has_a_link_to_the_school_placements_input_field
  end

  scenario 'source course does not have "about course" data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_without_data_i_try_to_copy

    when_i_visit_the_school_placement_edit_page
    and_i_select_the_other_course_from_the_copy_content_dropdown
    then_i_do_not_see_copied_course_data
    and_i_do_not_see_the_warning_that_changes_are_not_saved
  end

  scenario "copy course content options are available after validation" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_there_is_a_course_with_data_i_want_to_copy

    when_i_visit_the_school_placement_edit_page
    when_i_submit_without_data
    then_i_can_still_copy_content_from_another_course
  end

private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_submit_without_data
    fill_in "What will trainees do while in their placement schools?", with: ""
    click_on "Update what you will do on school placements"
  end

  def then_i_can_still_copy_content_from_another_course
    when_i_select_the_other_course_from_the_copy_content_dropdown

    then_i_see_the_copied_course_data
    and_i_see_the_warning_that_changes_are_not_saved
  end

  def and_there_is_a_course_with_data_i_want_to_copy
    course_to_copy("About this other course")
  end

  def and_there_is_a_course_with_both_school_placement_fields_i_want_to_copy
    @copied_course = create(
      :course,
      provider: current_user.providers.first,
      enrichments: [
        build(
          :course_enrichment,
          :published,
          placement_school_activities: "Both copied - activities",
          support_and_mentorship: "Both copied - mentorship",
        ),
      ],
    )
  end

  def and_there_is_a_course_without_data_i_try_to_copy
    course_to_copy(nil)
  end

  def course_to_copy(placement_school_activities)
    @copied_course ||= create(
      :course,
      provider: current_user.providers.first,
      enrichments: [build(:course_enrichment, :published, placement_school_activities:, support_and_mentorship: nil)],
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
    expect(page).to have_link "What will trainees do while in their placement schools?"
    expect(page).to have_content "Please check it and make your changes before saving"
  end

  def then_i_see_plural_copy_warning_for_school_placements
    expect(page).to have_content "Your changes are not yet saved"
    expect(page).to have_content "We have copied these fields from #{copied_course_name_and_code}:"
    expect(page).to have_link "What will trainees do while in their placement schools?"
    expect(page).to have_link "How will they be supported and mentored?"
    expect(page).to have_content "Please check them and make your changes before saving"
  end

  def and_i_do_not_see_the_warning_that_changes_are_not_saved
    expect(page).to have_no_content "Your change are not yet saved"
  end

  def and_the_warning_has_a_link_to_the_school_placements_input_field
    href = find_link("What will trainees do while in their placement schools?")[:href]
    school_placements_id = (find_field "What will trainees do while in their placement schools?")[:id]
    expect(school_placements_id).to eq(href.remove("#"))
  end

  def then_i_see_the_copied_course_data
    expect(find_field("What will trainees do while in their placement schools?").value).to eq @copied_course.enrichments.first.placement_school_activities
  end

  def then_i_do_not_see_copied_course_data
    expect(find_field("What will trainees do while in their placement schools?").value).to eq @course.enrichments.first.placement_school_activities
  end

  def when_i_visit_the_school_placement_edit_page
    visit fields_school_placement_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code,
    )
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
