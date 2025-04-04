# frozen_string_literal: true

require "rails_helper"
require_relative "provider_school_helper"

feature "Delete a provider's schools", { can_edit_current_and_next_cycles: false } do
  include ProviderSchoolHelper
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_schools_page
    then_i_should_see_a_list_of_schools
  end

  scenario "with no associated courses" do
    when_i_visit_the_publish_school_show_page
    and_i_click_remove_school_link
    then_i_am_on_the_school_delete_page
    when_i_click_cancel
    then_i_am_on_the_school_show_page

    and_i_click_remove_school_link
    and_i_click_remove_school_button
    then_i_am_on_the_index_page
    and_the_school_is_deleted
  end

  scenario "with associated course" do
    given_there_is_an_associated_course
    when_i_visit_the_publish_school_show_page
    and_i_click_remove_school_link
    then_i_am_on_the_school_delete_page
    and_i_cannot_delete_the_school
  end

  scenario "with discarded associated course" do
    given_there_is_an_associated_course
    and_i_delete_the_course
    when_i_visit_the_publish_school_show_page
    and_i_click_remove_school_link
    then_i_am_on_the_school_delete_page
    and_i_am_able_to_remove_the_school

    when_i_click_remove_school_button
    then_i_am_on_the_index_page
    and_the_school_is_deleted
  end

  def when_i_visit_the_publish_school_show_page
    publish_school_show_page.load(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, school_id: @site.id)
  end

  def and_i_click_remove_school_link
    click_link_or_button "Remove school"
  end

  def then_i_am_on_the_school_delete_page
    expect(publish_school_delete_page).to be_displayed
  end

  def when_i_click_cancel
    click_link_or_button "Cancel"
  end

  def and_i_click_remove_school_button
    click_link_or_button "Remove school"
  end
  alias_method :when_i_click_remove_school_button, :and_i_click_remove_school_button

  def and_the_school_is_deleted
    expect(provider.sites.count).to eq 0
  end

  def given_there_is_an_associated_course
    @course = create(:course, provider:)
    @course.sites << @site
  end

  def and_i_cannot_delete_the_school
    expect(publish_school_delete_page).to have_text("You cannot remove this school")
    expect(publish_school_delete_page).not_to have_remove_school_button
  end

  def and_i_delete_the_course
    visit delete_publish_provider_recruitment_cycle_course_path(
      provider_code: @course.provider.provider_code,
      recruitment_cycle_year: @course.recruitment_cycle.year,
      code: @course.course_code,
    )
    fill_in "Enter the course code to confirm", with: @course.course_code
    click_link_or_button "Yes I’m sure – delete this course"
  end

  def and_i_am_able_to_remove_the_school
    expect(page).to have_content("Remove school")
  end
end
