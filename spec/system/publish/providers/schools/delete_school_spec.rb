# frozen_string_literal: true

require "rails_helper"
require_relative "provider_school_helper"

RSpec.describe "Delete a provider's schools" do
  include ProviderSchoolHelper

  scenario "with no associated courses" do
    given_i_am_authenticated_as_a_provider_user_with_two_schools
    when_i_visit_the_schools_page
    then_i_see_both_schools_listed
    when_i_visit_the_publish_school_show_page
    and_i_click_remove_school_link
    then_i_am_on_the_school_delete_page
    when_i_click_back
    then_i_am_on_the_school_show_page

    and_i_click_remove_school_link
    when_i_click_cancel
    then_i_am_on_the_school_show_page

    and_i_click_remove_school_link
    and_i_click_remove_school_button
    then_i_am_on_the_index_page
    and_the_school_is_deleted
  end

  scenario "from the schools index page" do
    given_i_am_authenticated_as_a_provider_user_with_two_schools
    when_i_visit_the_schools_page
    and_i_click_remove_school_from_the_index
    then_i_am_on_the_school_delete_page
    when_i_click_back
    then_i_am_on_the_index_page

    and_i_click_remove_school_from_the_index
    when_i_click_cancel
    then_i_am_on_the_index_page

    and_i_click_remove_school_from_the_index
    and_i_click_remove_school_button
    then_i_am_on_the_index_page
    and_the_school_is_deleted
  end

  scenario "with associated course" do
    given_i_am_authenticated_as_a_provider_user_with_two_schools
    when_i_visit_the_schools_page
    then_i_see_both_schools_listed
    given_there_is_an_associated_course
    when_i_visit_the_publish_school_show_page
    and_i_click_remove_school_link
    then_i_am_on_the_school_delete_page
    and_i_cannot_delete_the_school
  end

  scenario "when the school becomes associated with a course before removal" do
    given_i_am_authenticated_as_a_provider_user_with_two_schools
    when_i_visit_the_schools_page
    then_i_see_both_schools_listed
    when_i_visit_the_publish_school_show_page
    and_i_click_remove_school_link
    then_i_am_on_the_school_delete_page

    given_there_is_an_associated_course
    when_i_click_remove_school_button
    then_i_see_the_school_could_not_be_removed
    and_the_school_is_not_deleted
  end

  scenario "with discarded associated course" do
    given_i_am_authenticated_as_a_provider_user_with_two_schools
    when_i_visit_the_schools_page
    then_i_see_both_schools_listed
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

  scenario "when it is the provider's only school" do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_schools_page
    then_i_see_a_list_of_schools
    when_i_visit_the_publish_school_show_page
    and_i_click_remove_school_link
    then_i_am_on_the_school_delete_page
    and_i_am_told_it_is_the_only_school
  end

  scenario "after the schools remodel cycle without a legacy site" do
    given_i_am_authenticated_as_a_provider_user_after_the_schools_remodel_cycle
    and_there_is_a_provider_school_without_a_legacy_site
    and_the_future_provider_has_a_second_school
    when_i_visit_the_schools_page_after_the_schools_remodel_cycle
    then_i_see_the_provider_school_listed_with_its_uuid

    when_i_click_the_provider_school
    then_i_see_the_provider_school_details

    when_i_remove_the_provider_school
    then_i_am_on_the_index_page
    and_the_provider_school_is_deleted
  end

  def given_i_am_authenticated_as_a_provider_user_with_two_schools
    given_i_am_authenticated_as_a_provider_user
    second_school
  end

  def second_school
    @second_school ||= create(
      :provider_school,
      provider:,
      gias_school: create(:gias_school, name: "Second School"),
      site_code: "Z",
    )
  end

  def then_i_see_both_schools_listed
    expect(publish_schools_index_page.schools.size).to eq(2)
    expect(publish_schools_index_page).to have_text(provider_school.location_name)
    expect(publish_schools_index_page).to have_text(second_school.location_name)
  end

  def given_i_am_authenticated_as_a_provider_user_after_the_schools_remodel_cycle
    given_i_am_authenticated(user: create(:user, providers: [future_provider]))
  end

  def and_there_is_a_provider_school_without_a_legacy_site
    expect(Site.find_by_uuid(future_provider_school.uuid)).to be_nil
  end

  def and_the_future_provider_has_a_second_school
    create(
      :provider_school,
      provider: future_provider,
      gias_school: create(:gias_school, name: "Second Future School"),
      site_code: "Z",
    )
  end

  def when_i_visit_the_schools_page_after_the_schools_remodel_cycle
    publish_schools_index_page.load(
      provider_code: future_provider.provider_code,
      recruitment_cycle_year: future_recruitment_cycle.year,
    )
  end

  def then_i_see_the_provider_school_listed_with_its_uuid
    row = school_row(future_gias_school.name)

    expect(row.address).to have_text(future_provider_school.full_address)
    expect(row.courses_count).to have_text("0 courses")
    expect(row.edit_link[:href]).to include(future_provider_school.uuid)
    expect(row.remove_link[:href]).to include(future_provider_school.uuid)
  end

  def when_i_click_the_provider_school
    school_row(future_gias_school.name).edit_link.click
  end

  def school_row(name)
    publish_schools_index_page.schools.find { |school| school.name.text.include?(name) }
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

  def provider_school
    @provider_school ||= provider.schools.find_by!(uuid: site.uuid)
  end

  def when_i_visit_the_publish_school_show_page
    publish_school_show_page.load(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, school_id: site.uuid)
  end

  def and_i_click_remove_school_link
    click_link_or_button "Remove school"
  end

  def and_i_click_remove_school_from_the_index
    school_row(provider_school.location_name).remove_link.click
  end

  def then_i_am_on_the_school_delete_page
    expect(publish_school_delete_page).to be_displayed
  end

  def when_i_click_cancel
    click_link_or_button "Cancel"
  end

  def when_i_click_back
    click_link_or_button "Back"
  end

  def and_i_click_remove_school_button
    click_link_or_button "Remove school"
  end
  alias_method :when_i_click_remove_school_button, :and_i_click_remove_school_button

  def and_the_school_is_deleted
    expect(provider.sites.reload).to be_empty
    expect(provider.schools.reload).to contain_exactly(second_school)
  end

  def and_the_school_is_not_deleted
    expect(provider.sites.reload.count).to eq 1
    expect(provider.schools.reload).to contain_exactly(provider_school, second_school)
  end

  def given_there_is_an_associated_course
    @course = create(:course, provider:)
    create(
      :course_school,
      course: @course,
      provider_school:,
      gias_school: provider_school.gias_school,
      site_code: provider_school.site_code,
    )
  end

  def and_i_cannot_delete_the_school
    expect(publish_school_delete_page).to have_text("You cannot remove this school")
    expect(page).to have_content("#{provider_school.location_name} is a school for courses run by #{provider.provider_name}.")
    expect(page).to have_content("To remove #{provider_school.location_name}, you must first remove the school from those courses.")
    expect(publish_school_delete_page).not_to have_remove_school_button
  end

  def and_i_am_told_it_is_the_only_school
    expect(publish_school_delete_page).to have_text("You cannot remove this school")
    expect(page).to have_content("#{provider_school.location_name} is the only school for #{provider.provider_name}.")
    expect(page).to have_content("To remove it, you must first add another school.")
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
