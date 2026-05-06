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

  scenario "i can detach a school from a published course (regression for QA bug)" do
    given_the_course_is_published_with_both_sites_running
    when_i_visit_the_publish_course_school_edit_page
    when_i_untick_site_one
    and_i_submit
    then_i_should_see_a_success_message
    and_only_site_two_is_attached
    and_site_one_site_status_is_destroyed
    and_the_basic_details_page_no_longer_lists_site_one
  end

  scenario "untick all then re-tick one school on a published course with three schools" do
    given_the_provider_has_three_sites
    given_the_course_is_published_with_all_three_sites_running
    when_i_visit_the_publish_course_school_edit_page
    when_i_untick_all_then_tick_only_site_two
    and_i_submit
    then_i_should_see_a_success_message
    and_only_site_two_is_attached_among_the_three
    and_site_one_and_three_site_statuses_are_destroyed
  end

  scenario "duplicate stale site_status rows do not break the untick (AASM regression)" do
    given_the_course_is_published_with_both_sites_running
    given_site_one_has_an_extra_stale_suspended_site_status
    when_i_visit_the_publish_course_school_edit_page
    when_i_untick_site_one
    and_i_submit
    then_i_should_see_a_success_message
    and_only_site_two_is_attached
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

  def given_the_course_is_published_with_both_sites_running
    provider.sites.each do |site|
      gias_school = GiasSchool.find_by!(urn: site.urn)
      course.site_statuses.create!(site:, status: :running, publish: :published)
      create(:course_school, course:, gias_school:, site_code: site.code)
    end
    course.update!(first_published_at: 1.day.ago) if course.respond_to?(:first_published_at)
  end

  def and_site_one_site_status_is_destroyed
    site_one = provider.sites.find_by(location_name: "Site 1")
    expect(course.reload.site_statuses.where(site: site_one)).to be_empty
  end

  def given_site_one_has_an_extra_stale_suspended_site_status
    # Mirrors the production data state that triggered AASM::InvalidTransition
    # for the QA-reported untick: a duplicate suspended row from an earlier
    # remove sat alongside the running one. find_by!(site:) used to grab the
    # suspended one and suspend! blew up.
    site_one = provider.sites.find_by(location_name: "Site 1")
    SiteStatus.create!(course:, site: site_one, status: :suspended, publish: :unpublished)
  end

  def and_the_basic_details_page_no_longer_lists_site_one
    visit details_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      course.course_code,
    )
    expect(page).to have_no_content("Site 1")
    expect(page).to have_content("Site 2")
  end

  def given_the_provider_has_three_sites
    provider.sites << build(:site, location_name: "Site 3")
    provider.save!
    site = provider.sites.find_by(location_name: "Site 3")
    gias_school = create(:gias_school, urn: site.urn)
    create(:provider_school, provider:, gias_school:, site_code: site.code)
  end

  def given_the_course_is_published_with_all_three_sites_running
    provider.sites.each do |site|
      gias_school = GiasSchool.find_by!(urn: site.urn)
      course.site_statuses.create!(site:, status: :running, publish: :published)
      create(:course_school, course:, gias_school:, site_code: site.code)
    end
    course.update!(first_published_at: 1.day.ago) if course.respond_to?(:first_published_at)
  end

  def when_i_untick_all_then_tick_only_site_two
    ["Site 1", "Site 2", "Site 3"].each do |label|
      box = publish_course_school_edit_page.vacancies.find { |el| el.find(".govuk-label").text == label }
      box.uncheck if box.checked?
    end
    publish_course_school_edit_page.vacancies.find { |el| el.find(".govuk-label").text == "Site 2" }.check
  end

  def and_only_site_two_is_attached_among_the_three
    expect(course.reload.sites.map(&:location_name)).to contain_exactly("Site 2")
  end

  def and_site_one_and_three_site_statuses_are_destroyed
    ["Site 1", "Site 3"].each do |name|
      site = provider.sites.find_by(location_name: name)
      expect(course.reload.site_statuses.where(site: site)).to be_empty
    end
  end

  def provider
    @current_user.providers.first
  end
end
