# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing course schools", travel: mid_cycle(2026) do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_provider_schools_mirror_the_sites
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
  end

  scenario "i can update the course schools" do
    then_i_should_see_a_list_of_schools
    when_i_update_the_course_schools
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_schools_are_updated
    and_the_new_model_course_school_row_exists
  end

  scenario "i can detach a school from the course" do
    given_the_course_already_has_both_sites
    when_i_untick_site_one
    and_i_submit
    then_i_should_see_a_success_message
    and_only_site_two_is_attached
    and_no_course_school_row_exists_for_site_one
  end

  scenario "updating with invalid data" do
    and_i_submit
    then_i_should_see_an_error_message
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          build(
            :provider,
            sites: [
              build(:site, location_name: "Site 1"),
              build(:site, location_name: "Site 2"),
            ],
          ),
        ],
      ),
    )
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(sites: [])
  end

  def when_i_visit_the_publish_course_school_edit_page
    publish_course_school_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
  end

  def then_i_should_see_a_list_of_schools
    expect(publish_course_school_edit_page.vacancy_names).to contain_exactly("Site 1", "Site 2")
  end

  def when_i_update_the_course_schools
    publish_course_school_edit_page.vacancies.find { |el|
      el.find(".govuk-label").text == "Site 1"
    }.check
  end

  def and_i_submit
    publish_course_school_edit_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.saved", value: "School"))
  end

  def and_the_course_schools_are_updated
    expect(course.reload.sites.map(&:location_name)).to contain_exactly("Site 1")
  end

  def then_i_should_see_an_error_message
    expect(publish_course_school_edit_page).to have_content(
      I18n.t("activemodel.errors.models.publish/course_school_form.attributes.site_ids.no_schools"),
    )
  end

  def and_provider_schools_mirror_the_sites
    provider.sites.each do |site|
      gias_school = create(:gias_school, urn: site.urn)
      create(:provider_school, provider:, gias_school:, site_code: site.code)
    end
  end

  def and_the_new_model_course_school_row_exists
    site = provider.sites.find_by(location_name: "Site 1")
    gias_school = GiasSchool.find_by!(urn: site.urn)
    course_school = course.reload.schools.find_by(gias_school:)
    expect(course_school).to be_present
    expect(course_school.site_code).to eq(site.code)
  end

  def given_the_course_already_has_both_sites
    provider.sites.each do |site|
      gias_school = GiasSchool.find_by!(urn: site.urn)
      course.site_statuses.create!(site:, status: :new_status, publish: :unpublished)
      create(:course_school, course:, gias_school:, site_code: site.code)
    end
    visit current_path
  end

  def when_i_untick_site_one
    publish_course_school_edit_page.vacancies.find { |el|
      el.find(".govuk-label").text == "Site 1"
    }.uncheck
  end

  def and_only_site_two_is_attached
    expect(course.reload.sites.map(&:location_name)).to contain_exactly("Site 2")
  end

  def and_no_course_school_row_exists_for_site_one
    site_one = provider.sites.find_by(location_name: "Site 1")
    gias_school_one = GiasSchool.find_by!(urn: site_one.urn)
    expect(course.reload.schools.where(gias_school: gias_school_one)).to be_empty
  end

  def provider
    @current_user.providers.first
  end
end
