# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publishing a course that is allowed to have no schools", travel: mid_cycle(2026) do
  before do
    FeatureFlag.activate(:course_publishing_uses_new_school_model)
    given_i_am_authenticated_as_a_provider_user
    and_provider_schools_mirror_the_sites
    and_there_is_an_exempt_salaried_course_with_one_school
  end

  scenario "the provider removes every school and then publishes the course" do
    when_i_visit_the_schools_page
    and_i_untick_the_only_school
    and_i_submit
    then_i_see_the_schools_were_saved
    and_the_course_has_no_schools

    when_i_visit_the_course_page
    then_i_see_the_publish_button
    when_i_publish_the_course
    then_the_course_is_published
    and_the_publish_button_is_gone
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(:user, providers: [build(:provider, sites: [build(:site, location_name: "Site 1")])]),
    )
  end

  def provider
    current_user.providers.first
  end

  def and_provider_schools_mirror_the_sites
    provider.sites.each do |site|
      gias_school = create(:gias_school, urn: site.urn)
      create(:provider_school, provider:, gias_school:, site_code: site.code)
    end
  end

  def and_there_is_an_exempt_salaried_course_with_one_school
    given_a_course_exists(
      :with_salary,
      :with_gcse_equivalency,
      :with_accrediting_provider,
      :closed,
      publish_without_schools_allowed: true,
      accrediting_provider: build(:accredited_provider),
      enrichments: [build(:course_enrichment, :initial_draft, interview_location: "in person")],
      study_sites: [build(:site, :study_site)],
    )

    site = provider.sites.first
    gias_school = GiasSchool.find_by!(urn: site.urn)
    course.site_statuses.create!(site:, status: :new_status, publish: :unpublished)
    create(:course_school, course:, gias_school:, site_code: site.code)
  end

  def when_i_visit_the_schools_page
    publish_course_school_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
  end

  def and_i_untick_the_only_school
    publish_course_school_edit_page.vacancies.find { |el|
      el.find(".govuk-label").text == "Site 1"
    }.uncheck
  end

  def and_i_submit
    publish_course_school_edit_page.submit.click
  end

  def then_i_see_the_schools_were_saved
    expect(page).to have_content("Schools updated")
  end

  def and_the_course_has_no_schools
    expect(course.reload.schools).to be_empty
  end

  def when_i_visit_the_course_page
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
  end

  def then_i_see_the_publish_button
    expect(page).to have_button("Publish course")
  end

  def when_i_publish_the_course
    click_on "Publish course"
  end

  def then_the_course_is_published
    expect(page).to have_content("Your course has been published.")
    expect(course.reload.is_published?).to be(true)
  end

  def and_the_publish_button_is_gone
    expect(page).to have_no_button("Publish course")
  end
end
