# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish - Placement schools list display", type: :system do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  # The count has to agree with the ticked boxes underneath it, so both come
  # from CourseSchools::Identity.
  describe "the count of attached schools" do
    scenario "shows the number of schools attached" do
      given_a_course_with_attached_sites(count: 3)
      when_i_visit_the_publish_course_school_edit_page
      then_i_see_the_attached_count("You currently have 3 schools attached to this course")
    end

    scenario "uses the singular for a single attached school" do
      given_a_course_with_attached_sites(count: 1)
      when_i_visit_the_publish_course_school_edit_page
      then_i_see_the_attached_count("You currently have 1 school attached to this course")
    end

    scenario "handles a course with no attached schools" do
      given_a_course_with_attached_sites(count: 0)
      when_i_visit_the_publish_course_school_edit_page
      then_i_see_the_attached_count("You do not have any schools attached to this course")
    end

    scenario "counts schools attached through the new model" do
      given_a_course_with_attached_course_schools(count: 2)
      when_i_visit_the_publish_course_school_edit_page
      then_i_see_the_attached_count("You currently have 2 schools attached to this course")
    end

    # It cannot be rendered as a checkbox, so counting it would contradict the
    # list. DataHub::SchoolsRemodelPreflight::Report counts these.
    scenario "ignores a site that has no Provider::School" do
      given_a_course_attached_to_an_unpaired_site
      when_i_visit_the_publish_course_school_edit_page
      then_i_see_the_attached_count("You do not have any schools attached to this course")
    end
  end

  describe "the school hint text" do
    scenario "shows the address without duplicating the school name" do
      given_the_provider_has_a_named_school
      given_a_course_with_attached_sites(count: 0)
      when_i_visit_the_publish_course_school_edit_page
      then_the_school_label_shows_the_name
      and_the_hint_shows_the_address_without_the_name
    end
  end

  def given_i_am_authenticated_as_a_provider_user
    @provider = create(:provider)
    @sites = create_list(:site, 3, provider: @provider)
    @user = create(:user, providers: [@provider])
    given_i_am_authenticated(user: @user)
    @provider.reload
    pair_provider_schools_with_sites(@provider)
  end

  def given_a_course_attached_to_an_unpaired_site
    @course = create(:course, provider: @provider, sites: [])
    unpaired_site = create(:site, provider: @provider, code: "ZZ", urn: create(:gias_school).urn)
    @course.site_statuses.create!(site: unpaired_site, status: :new_status, publish: :unpublished)
  end

  def given_a_course_with_attached_sites(count:)
    @course = create(:course, provider: @provider, sites: [])
    @provider.sites.first(count).each do |site|
      @course.site_statuses.create!(site:, status: :new_status, publish: :unpublished)
    end
  end

  def given_a_course_with_attached_course_schools(count:)
    @course = create(:course, provider: @provider, sites: [])
    @provider.schools.first(count).each do |provider_school|
      create(:course_school, course: @course, gias_school: provider_school.gias_school, provider_school:)
    end
  end

  # The picker reads names and addresses off gias_school now, so the paired
  # Provider::School is what carries them.
  def given_the_provider_has_a_named_school
    gias_school = create(
      :gias_school,
      name: "Belvidere School",
      address1: "Belvidere Lane",
      address2: nil,
      address3: nil,
      town: "Shrewsbury",
      county: "Shropshire",
      postcode: "SY2 5RJ",
    )
    uuid = SecureRandom.uuid
    create(:site, provider: @provider, uuid:, code: "BV", urn: gias_school.urn)
    @school = create(:provider_school, provider: @provider, gias_school:, site_code: "BV", uuid:)
  end

  def when_i_visit_the_publish_course_school_edit_page
    publish_course_school_edit_page.load(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      course_code: @course.course_code,
    )
  end

  def then_i_see_the_attached_count(text)
    expect(page).to have_content(text)
  end

  def then_the_school_label_shows_the_name
    expect(page).to have_css(".govuk-checkboxes__label", text: "Belvidere School")
  end

  def and_the_hint_shows_the_address_without_the_name
    hint = page.find(".govuk-hint", text: "Belvidere Lane")
    expect(hint.text).to eq("Belvidere Lane, Shrewsbury, Shropshire, SY2 5RJ")
    expect(hint.text).not_to include("Belvidere School")
  end
end
