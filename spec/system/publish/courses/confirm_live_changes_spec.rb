# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Confirming live changes before publishing course edits" do
  before do
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  scenario "published course shows interstitial for what you will study, then saves on confirm" do
    given_a_published_course
    and_the_course_was_last_published_yesterday
    when_i_edit_what_you_will_study
    then_i_see_the_live_changes_interstitial(section: "What you will study")
    and_the_what_you_will_study_content_is_not_saved_yet

    when_i_confirm_publishing_live_changes
    then_i_see_the_live_changes_success_message(section: "What you will study")
    and_the_what_you_will_study_content_is_saved
    and_the_last_updated_timestamp_is_refreshed
  end

  scenario "draft course skips the interstitial for what you will study" do
    given_a_draft_course
    when_i_edit_what_you_will_study
    then_i_should_not_see_the_live_changes_interstitial
    then_i_see_a_simple_success_message(section: "What you will study")
    and_the_what_you_will_study_content_is_saved
  end

  scenario "published course shows interstitial for age range, then saves on confirm" do
    given_a_published_course
    and_the_course_was_last_published_yesterday
    when_i_edit_age_range
    then_i_see_the_live_changes_interstitial(section: "Age range")
    and_the_age_range_is_not_saved_yet

    when_i_confirm_publishing_live_changes
    then_i_see_the_live_changes_success_message(section: "Age range")
    and_the_age_range_is_saved
    and_the_last_updated_timestamp_is_refreshed
  end

  # The section asks which courses the change is for instead, and that page has
  # a confirmation of its own.
  scenario "schools update on a published course does not show the interstitial" do
    given_a_published_course_with_schools
    and_the_course_was_last_published_yesterday
    when_i_update_course_schools
    then_i_should_not_see_the_live_changes_interstitial
    and_i_apply_the_change_to_this_course_only
    then_i_should_not_see_the_live_changes_interstitial
    expect(page).to have_content("School updated")
    and_the_last_updated_timestamp_is_refreshed
  end

private

  def given_a_published_course
    given_a_course_exists(:published)
  end

  def and_the_course_was_last_published_yesterday
    @previous_last_published_at = 1.day.ago.change(usec: 0)
    course.enrichments.published.update_all(last_published_timestamp_utc: @previous_last_published_at)
  end

  def given_a_draft_course
    given_a_course_exists(:draft_enrichment)
  end

  def given_a_published_course_with_schools
    site = create(:site, :with_provider_school, location_name: "Site 1", provider:)
    given_a_course_exists(:published, sites: [site])
    create(:site, :with_provider_school, location_name: "Site 2", provider:)
  end

  def when_i_edit_what_you_will_study
    visit fields_what_you_will_study_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      course.course_code,
    )

    @theoretical_training = "Trainees will attend seminars and workshops"
    fill_in "What will trainees do during their theoretical training?", with: @theoretical_training
    click_button "Update what you will study"
  end

  def when_i_edit_age_range
    publish_courses_age_range_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
    publish_courses_age_range_edit_page.five_to_eleven.click
    publish_courses_age_range_edit_page.continue.click
  end

  def when_i_update_course_schools
    publish_course_school_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
    publish_course_school_edit_page.vacancies.find { |el|
      el.find(".govuk-label").text == "Site 2"
    }.check
    publish_course_school_edit_page.submit.click
  end

  def then_i_see_the_live_changes_interstitial(section:)
    expect(page).to have_content(
      I18n.t("publish.courses.confirm_live_changes.heading", section:),
    )
    expect(page).to have_content(I18n.t("publish.courses.confirm_live_changes.body"))
  end

  def when_i_confirm_publishing_live_changes
    and_i_confirm_publishing_live_changes
  end

  def then_i_see_the_live_changes_success_message(section:)
    expect(page).to have_content("#{section} updated")
    expect(page).to have_content(I18n.t("success.changes_now_live"))
  end

  def then_i_see_a_simple_success_message(section:)
    expect(page).to have_content(I18n.t("success.saved", value: section))
    expect(page).to have_no_content(I18n.t("success.changes_now_live"))
  end

  def and_the_what_you_will_study_content_is_not_saved_yet
    expect(course.reload.enrichments.find_or_initialize_draft.theoretical_training_activities)
      .not_to eq(@theoretical_training)
  end

  def and_the_what_you_will_study_content_is_saved
    expect(course.reload.enrichments.find_or_initialize_draft.theoretical_training_activities)
      .to eq(@theoretical_training)
  end

  def and_the_age_range_is_not_saved_yet
    expect(course.reload.age_range_in_years).to eq("3_to_7")
  end

  def and_the_age_range_is_saved
    expect(course.reload.age_range_in_years).to eq("5_to_11")
  end

  def and_the_last_updated_timestamp_is_refreshed
    expect(course.reload.last_published_at).to be_within(5.seconds).of(Time.zone.now)
    expect(course.last_published_at).to be > @previous_last_published_at
  end

  def provider
    @current_user.providers.first
  end
end
