# frozen_string_literal: true

require "rails_helper"

feature "Publishing a course when course ratifying provider is invalid", travel: Find::CycleTimetable.mid_cycle do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "Add accredited partner to provider and provider has no accredited partners, change ratifying provider of course then publish" do
    and_the_provider_has_no_accredited_partners
    and_there_is_a_draft_course_with_an_unaccredited_ratifying_provider

    # Publising is invalid
    when_i_visit_the_course_page
    and_i_click_the_publish_button
    then_i_should_see_an_error_message_that_ratifying_provider_is_not_accredited

    # Add accrediting provider to provider
    when_i_click_the_error_message_link
    then_it_takes_me_to_the_accredited_providers_page
    when_i_click_add_an_accredited_partner
    and_i_search_for_an_accredited_provider
    and_i_confirm_creation_of_the_accredited_partnership
    then_i_see_that_the_accredited_partnership_has_been_added

    # Publishing is invalid
    when_i_visit_the_course_page
    and_i_click_the_publish_button
    then_i_should_see_an_error_message_that_ratifying_provider_is_not_accredited

    # Clicking error message allows user to select accrediting provider
    when_i_click_the_error_message_link
    and_i_choose_the_new_ratifying_provider
    and_i_click_the_publish_button
    then_i_should_see_a_success_message
  end

  scenario "Select valid ratifying provider to course and publish" do
    and_the_provider_has_a_valid_accrediting_provider
    and_there_is_a_draft_course_without_accrediting_provider
    and_an_accredited_provider_exists

    # Publising is invalid
    when_i_visit_the_course_page
    and_i_click_the_publish_button
    then_i_should_see_an_error_message_for_the_ratifying_provider

    # Clicking error message allows user to select ratifying provider
    when_i_click_the_select_accredited_partners_error_message_link
    and_i_choose_the_new_ratifying_provider
    and_i_click_the_publish_button
    then_i_should_see_a_success_message
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def and_the_provider_has_a_valid_accrediting_provider
    provider = @user.providers.first
    provider.accredited_partnerships.create(accredited_provider: accredited_provider)
  end

  def and_the_provider_has_no_accredited_partners
    expect(provider.accredited_partners).to be_empty
  end

  def and_there_is_a_draft_course_without_accrediting_provider
    given_a_course_exists(
      :with_gcse_equivalency,
      enrichments: [create(:course_enrichment, :initial_draft)],
      sites: [create(:site, location_name: "location 1")],
      study_sites: [create(:site, :study_site)],
    )
  end

  def and_there_is_a_draft_course_with_an_unaccredited_ratifying_provider
    given_a_course_exists(
      :with_gcse_equivalency,
      accrediting_provider: provider,
      enrichments: [create(:course_enrichment, :initial_draft)],
      sites: [create(:site, location_name: "location 1")],
      study_sites: [create(:site, :study_site)],
    )
  end

  def when_i_visit_the_course_page
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content("Your course has been published.")
  end

  def then_i_should_see_an_error_message_that_ratifying_provider_is_not_accredited
    expect(publish_provider_courses_show_page.error_messages).to include("Update the accredited provider")
  end

  def then_i_should_see_an_error_message_for_the_ratifying_provider
    expect(publish_provider_courses_show_page.error_messages).to include("Select an accredited provider")
  end

  def when_i_click_the_error_message_link
    publish_provider_courses_show_page.errors.first.link.click
  end

  def then_it_takes_me_to_the_accredited_providers_page
    expect(publish_courses_ratifying_providers_page).to be_displayed
  end

  def when_i_click_add_an_accredited_partner
    publish_courses_accredited_providers_page.add_new_link.click
    expect(publish_provider_accredited_providers_search_page).to be_displayed
  end

  def and_i_search_for_an_accredited_provider
    publish_provider_accredited_providers_search_page.search_input.set(accredited_provider.provider_name)
    publish_provider_accredited_providers_search_page.continue_button.click
    choose accredited_provider.name_and_code
    publish_provider_accredited_providers_search_page.continue_button.click
  end

  def and_i_confirm_creation_of_the_accredited_partnership
    publish_new_accredited_provider_page.submit.click
  end

  def then_i_see_that_the_accredited_partnership_has_been_added
    expect(page).to have_content("Accredited provider added")
  end

  def and_i_click_the_publish_button
    publish_provider_courses_show_page.publish_button.click
  end

  def when_i_click_the_select_accredited_partners_error_message_link
    page.click_link_or_button("Select an accredited provider")
  end

  def and_i_choose_the_new_ratifying_provider
    choose accredited_provider.provider_name
    page.click_link_or_button("Update accredited provider")
    expect(page).to have_content("Accredited provider updated")
  end

  def and_an_accredited_provider_exists
    accredited_provider
  end

  def accredited_provider
    @accredited_provider ||= create(:provider, :accredited_provider)
  end

  def provider
    @current_user.providers.first
  end
end
