# frozen_string_literal: true

require "rails_helper"

RSpec.describe "selection schools" do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_that_sites_exist
    when_i_visit_the_publish_courses_new_schools_page
  end

  scenario "selecting multiple schools" do
    when_i_select_a_school
    and_i_click_continue
    then_i_am_met_with_the_accredited_provider_page
  end

  scenario "invalid entries" do
    and_i_click_continue
    then_i_am_met_with_errors
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def and_that_sites_exist
    provider.sites << create_list(:site, 3)
    mirror_provider_schools_from_sites(provider)
  end

  def when_i_visit_the_publish_courses_new_schools_page
    publish_courses_new_schools_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Find::CycleTimetable.current_year, query: schools_params)
  end

  def when_i_select_a_school
    publish_courses_new_schools_page.check(schools.first.location_name)
    publish_courses_new_schools_page.check(schools.second.location_name)
  end

  def and_i_click_continue
    publish_courses_new_schools_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def schools
    @schools ||= CourseSchools::Identity.new(provider:).available_schools
  end

  def mirror_provider_schools_from_sites(provider)
    provider.sites.school.each do |site|
      create(
        :provider_school,
        provider:,
        gias_school: create_gias_school_from_site(site),
        site_code: site.code,
      )
    end

    provider.reload
  end

  def create_gias_school_from_site(site)
    create(
      :gias_school,
      urn: site.urn,
      name: site.location_name,
      address1: site.address1,
      address2: site.address2,
      address3: site.address3,
      town: site.town,
      county: site.address4,
      postcode: site.postcode,
    )
  end

  def then_i_am_met_with_the_accredited_provider_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Find::CycleTimetable.current_year}/courses/ratifying-provider/new", ignore_query: true)
    expect(page).to have_content("Accredited provider")
  end

  def then_i_am_met_with_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select at least one school")
  end
end
