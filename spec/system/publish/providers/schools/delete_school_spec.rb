# frozen_string_literal: true

require "rails_helper"
require_relative "provider_school_helper"

RSpec.describe "Delete a provider's schools" do
  include ProviderSchoolHelper

  scenario "with no associated courses" do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_schools_page
    then_i_see_a_list_of_schools
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
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_schools_page
    then_i_see_a_list_of_schools
    given_there_is_an_associated_course
    when_i_visit_the_publish_school_show_page
    and_i_click_remove_school_link
    then_i_am_on_the_school_delete_page
    and_i_cannot_delete_the_school
  end

  scenario "when the school becomes associated with a course before removal" do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_schools_page
    then_i_see_a_list_of_schools
    when_i_visit_the_publish_school_show_page
    and_i_click_remove_school_link
    then_i_am_on_the_school_delete_page

    given_there_is_an_associated_course
    when_i_click_remove_school_button
    then_i_see_the_school_could_not_be_removed
    and_the_school_is_not_deleted
  end

  scenario "with discarded associated course" do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_schools_page
    then_i_see_a_list_of_schools
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

  scenario "after the schools remodel cycle without a legacy site" do
    given_i_am_authenticated_as_a_provider_user_after_the_schools_remodel_cycle
    and_there_is_a_provider_school_without_a_legacy_site
    when_i_visit_the_schools_page_after_the_schools_remodel_cycle
    then_i_see_the_provider_school_listed_with_its_uuid

    when_i_click_the_provider_school
    then_i_see_the_provider_school_details

    when_i_remove_the_provider_school
    then_i_am_on_the_index_page
    and_the_provider_school_is_deleted
  end

  def given_i_am_authenticated_as_a_provider_user_after_the_schools_remodel_cycle
    given_i_am_authenticated(user: create(:user, providers: [future_provider]))
  end

  def and_there_is_a_provider_school_without_a_legacy_site
    expect(Site.find_by_uuid(future_provider_school.uuid)).to be_nil
  end

  def when_i_visit_the_schools_page_after_the_schools_remodel_cycle
    publish_schools_index_page.load(
      provider_code: future_provider.provider_code,
      recruitment_cycle_year: future_recruitment_cycle.year,
    )
  end

  def then_i_see_the_provider_school_listed_with_its_uuid
    expect(publish_schools_index_page.schools.first.name).to have_text(future_gias_school.name)
    expect(publish_schools_index_page.schools.first.code).to have_text("- (dash)")
    expect(publish_schools_index_page.schools.first.urn).to have_text(future_gias_school.urn)
    expect(publish_schools_index_page.schools.first.edit_link[:href]).to include(future_provider_school.uuid)
  end

  def when_i_click_the_provider_school
    publish_schools_index_page.schools.first.edit_link.click
  end

  def then_i_see_the_provider_school_details
    expect(publish_school_show_page).to be_displayed
    expect(page).to have_content("Future School (Main Site)")
    expect(page).to have_content("School code-", normalize_ws: true)
    expect(page).to have_content("URN654321", normalize_ws: true)
    expect(page).to have_content("Address 1 Future Road Future Building Future Quarter Future Town Future County FT1 1AA", normalize_ws: true)
  end

  def when_i_remove_the_provider_school
    publish_school_show_page.remove_school_link.click
    publish_school_delete_page.remove_school_button.click
  end

  def and_the_provider_school_is_deleted
    expect(Provider::School.where(id: future_provider_school.id)).to be_empty
  end

  def future_recruitment_cycle
    @future_recruitment_cycle ||= create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year + 1)
  end

  def future_provider
    @future_provider ||= create(:provider, recruitment_cycle: future_recruitment_cycle)
  end

  def future_provider_school
    @future_provider_school ||= create(:provider_school, provider: future_provider, gias_school: future_gias_school, site_code: "-")
  end

  def future_gias_school
    @future_gias_school ||= create(
      :gias_school,
      name: "Future School",
      urn: "654321",
      address1: "1 Future Road",
      address2: "Future Building",
      address3: "Future Quarter",
      town: "Future Town",
      county: "Future County",
      postcode: "FT1 1AA",
    )
  end

  def when_i_visit_the_publish_school_show_page
    publish_school_show_page.load(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, school_id: site.uuid)
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

  def and_the_school_is_not_deleted
    expect(provider.sites.count).to eq 1
  end

  def given_there_is_an_associated_course
    @course = create(:course, provider:)
    create(
      :course_school,
      course: @course,
      provider_school: provider.schools.first,
      gias_school: provider.schools.first.gias_school,
      site_code: provider.schools.first.site_code,
    )
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

  def then_i_see_the_school_could_not_be_removed
    expect(publish_school_delete_page).to be_displayed
    expect(page).to have_content("This school could not be removed because it is used by a course")
  end
end
