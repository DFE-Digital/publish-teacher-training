# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing course schools with a closed school", travel: mid_cycle(2026) do
  scenario "a school whose GIAS record has closed is not offered" do
    given_i_am_signed_in_with_an_open_and_a_closed_school
    and_there_is_a_course_with_no_schools_attached
    when_i_visit_the_publish_course_school_edit_page
    then_i_see_the_available_school
    and_i_do_not_see_the_closed_school
  end

  scenario "a closed school already attached to the course is still listed, flagged as closed" do
    given_i_am_signed_in_with_an_open_and_a_closed_school
    and_the_course_already_has_the_closed_school_attached
    when_i_visit_the_publish_course_school_edit_page
    then_i_see_the_available_school
    and_the_closed_school_is_listed_and_tagged_closed
    and_i_can_keep_it_attached_by_submitting_unchanged
  end

  def given_i_am_signed_in_with_an_open_and_a_closed_school
    closed_gias_school = create(:gias_school, :closed, urn: "654321")
    @closed_site = build(:site, location_name: "Closed School", urn: closed_gias_school.urn)
    @provider = create(
      :provider,
      sites: [build(:site, :with_gias_school, location_name: "Available School", urn: "123456"), @closed_site],
    )

    given_i_am_authenticated(user: create(:user, providers: [@provider]))
  end

  def and_there_is_a_course_with_no_schools_attached
    @course = create(:course, provider: @provider, site_statuses: [])
  end

  def and_the_course_already_has_the_closed_school_attached
    @course = create(
      :course,
      provider: @provider,
      site_statuses: [build(:site_status, :new_status, :unpublished, site: @closed_site)],
    )
  end

  def when_i_visit_the_publish_course_school_edit_page
    visit schools_publish_provider_recruitment_cycle_course_path(
      @provider.provider_code,
      @provider.recruitment_cycle_year,
      @course.course_code,
    )
  end

  def then_i_see_the_available_school
    expect(page).to have_css(".govuk-checkboxes__label", text: "Available School")
  end

  def and_i_do_not_see_the_closed_school
    expect(page).to have_no_css(".govuk-checkboxes__label", text: "Closed School")
  end

  def and_the_closed_school_is_listed_and_tagged_closed
    within(page.find(".govuk-checkboxes__label", text: "Closed School")) do
      expect(page).to have_css(".govuk-tag", text: "Closed")
    end

    expect(page).to have_field("Closed School Closed", type: "checkbox", checked: true)
  end

  def and_i_can_keep_it_attached_by_submitting_unchanged
    click_on "Update placement schools"

    expect(@course.reload.sites.map(&:location_name)).to include("Closed School")
  end
end
