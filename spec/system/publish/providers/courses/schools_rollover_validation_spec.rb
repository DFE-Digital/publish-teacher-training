require "rails_helper"

RSpec.describe "Publish - Schools validation during 2026 rollover", service: :publish, type: :system do
  include DfESignInUserHelper

  let(:frozen_time) { Time.zone.local(2025, 9, 10, 12, 0, 0) }
  let!(:recruitment_cycle) do
    create(:recruitment_cycle, year: 2026, application_start_date: frozen_time - 15.days)
  end
  let!(:provider) { create(:provider, recruitment_cycle:, provider_code: "ABC") }
  let!(:accredited_provider) { create(:provider, :accredited_provider, recruitment_cycle:) }
  let!(:site_one) { create(:site, provider:, location_name: "School A") }
  let!(:site_two) { create(:site, provider:, location_name: "School B") }
  let!(:course)   { create(:course, :publishable, provider:, course_code: "XYZ", sites: [site_one, site_two], accrediting_provider: accredited_provider) }
  let(:user)      { create(:user, providers: [provider]) }

  before do
    travel_to frozen_time
    sign_in_system_test(user:)
  end

  after { travel_back }

  scenario "Publishing from course page shows rollover school validation errors" do
    given_i_am_on_the_course_page
    when_i_click_publish_course
    then_i_should_see_the_details_page_with_error_inset_for_schools
    when_i_click_the_error_summary_link
    then_i_should_stay_on_publish_page_with_error_inset_for_schools
    when_i_click_the_inset_link_to_schools_page
    then_i_should_be_on_schools_page_with_error_anchor
    when_i_click_update_schools
    when_i_click_publish_course
    then_course_is_published
  end

  scenario "Publishing from details page shows rollover school validation errors" do
    given_i_am_on_the_course_details_page
    when_i_click_publish_course
    then_i_should_see_the_school_validation_error_summary_linking_to_publish_anchor
    when_i_click_the_error_summary_link
    then_i_should_stay_on_publish_page_with_error_inset_for_schools
    when_i_click_the_inset_link_to_schools_page
    then_i_should_be_on_schools_page_with_error_anchor
  end

  def given_i_am_on_the_course_page
    visit publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      recruitment_cycle.year,
      course.course_code,
    )
  end

  def given_i_am_on_the_course_details_page
    visit details_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      recruitment_cycle.year,
      course.course_code,
    )
  end

  def when_i_click_publish_course
    click_button "Publish course"
  end

  def then_i_should_see_the_school_validation_error_summary_linking_to_publish_anchor
    expect(page).to have_content("There is a problem")
    error_links = all("a", text: "Check the schools for this course")
    expect(error_links.size).to eq(2)
    expect(error_links[0][:href]).to eq("/publish/organisations/ABC/2026/courses/XYZ/publish#school-summary-link")
    expect(error_links[1][:href]).to eq("/publish/organisations/ABC/2026/courses/XYZ/schools?display_errors=true")
  end

  def when_i_click_the_error_summary_link
    all("a", text: "Check the schools for this course").first.click
  end

  def then_i_should_see_the_details_page_with_error_inset_for_schools
    within(".app-inset-text--error") do
      expect(page).to have_content("School A")
      expect(page).to have_content("School B")
      school_link = page.find("a", text: "Check the schools for this course")
      expect(school_link[:href]).to eq(
        schools_publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          recruitment_cycle.year,
          course.course_code,
          display_errors: true,
        ),
      )
    end
  end

  def then_i_should_stay_on_publish_page_with_error_inset_for_schools
    within(".app-inset-text--error") do
      expect(page).to have_content("School A")
      expect(page).to have_content("School B")
      school_link = page.find("a", text: "Check the schools for this course")
      expect(school_link[:href]).to eq(
        schools_publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          recruitment_cycle.year,
          course.course_code,
          display_errors: true,
        ),
      )
    end
  end

  def when_i_click_the_inset_link_to_schools_page
    within(".app-inset-text--error") do
      page.find("a", text: "Check the schools for this course").click
    end
  end

  def then_i_should_be_on_schools_page_with_error_anchor
    expected_path = schools_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      recruitment_cycle.year,
      course.course_code,
      display_errors: true,
    )

    expect(page).to have_current_path(expected_path)

    expect(page).to have_content("There is a problem")

    error_links = all("a", text: "Check the schools for this course")
    expect(error_links).not_to be_empty

    expect(error_links.first[:href]).to eq("#publish-course-school-form-site-ids-field-error")
  end

  def when_i_click_update_schools
    click_link_or_button "Update placement schools"
  end

  def then_course_is_published
    expect(page).to have_content("Your course has been published.")
    expect(course.reload.is_published?).to be(true)
  end
end
