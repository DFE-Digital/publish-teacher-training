# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing course ratifying provider" do
  scenario "published" do
    given_i_am_authenticated_as_a_training_provider_user
    and_there_is_a_published_course_i_want_to_edit
    when_i_visit_the_course_details_page
    then_i_do_not_see_a_change_link_for_ratifying_provider
  end

  scenario "unratified and unpublished with no accredited partnerships" do
    given_i_am_authenticated_as_a_training_provider_user
    and_there_is_an_unratified_and_unpublished_course_i_want_to_edit

    when_i_visit_the_course_details_page
    then_i_see_a_message_to_add_an_ratifying_provider
  end

  scenario "unratified and unpublished with one accredited partnership" do
    given_i_am_authenticated_as_a_training_provider_user
    and_there_is_an_unratified_and_unpublished_course_i_want_to_edit
    and_there_is_a_second_provider_partnership

    when_i_visit_the_course_details_page
    then_i_see_a_message_to_select_an_ratifying_provider
  end

  scenario "unpublished with one accredited partnerships" do
    given_i_am_authenticated_as_a_training_provider_user
    and_there_is_a_unpublished_course_i_want_to_edit

    when_i_visit_the_course_details_page
    then_i_do_not_see_a_change_link_for_ratifying_provider
  end

  scenario "unpublished with two accredited partnerships" do
    given_i_am_authenticated_as_a_training_provider_user
    and_there_is_a_unpublished_course_i_want_to_edit
    and_there_is_a_second_provider_partnership

    when_i_visit_the_course_details_page
    and_i_click_to_change_the_ratifying_provider
    then_i_can_choose_a_different_accredited_provider

    when_i_click_update
    then_i_see_a_success_message
    and_i_see_the_ratifying_provider_is_updated
  end

  scenario "unpublished with an accredited partnership, updating without selecting one" do
    given_i_am_authenticated_as_a_training_provider_user
    and_there_is_an_unpublished_course_ratified_by_a_non_partner
    and_there_is_a_second_provider_partnership

    when_i_visit_the_course_details_page
    and_i_click_to_change_the_ratifying_provider
    and_i_click_update
    then_i_see_an_error_to_select_an_accredited_provider
  end

  scenario "unpublished with no accredited partnerships" do
    given_i_am_authenticated_as_a_training_provider_user
    and_there_is_an_unpublished_course_ratified_by_a_non_partner

    when_i_visit_the_course_details_page
    and_i_click_to_change_the_ratifying_provider
    then_i_am_told_to_add_an_accredited_provider_first
    and_i_cannot_update_the_ratifying_provider
  end

private

  def and_there_is_an_unpublished_course_ratified_by_a_non_partner
    given_a_course_exists(:unpublished, accrediting_provider: create(:accredited_provider))
  end

  def and_i_click_update
    click_on "Update accredited provider"
  end

  def then_i_see_an_error_to_select_an_accredited_provider
    expect(page).to have_css(".govuk-error-summary", text: "Select an accredited provider")
    expect(page).to have_css(".govuk-error-message", text: "Select an accredited provider")
  end

  def then_i_am_told_to_add_an_accredited_provider_first
    expect(page).to have_content("You need to add an accredited provider before you can select one for this course.")
    expect(page).to have_link("Add accredited provider")
  end

  def and_i_cannot_update_the_ratifying_provider
    expect(page).to have_no_button("Update accredited provider")
  end

  def given_i_am_authenticated_as_a_training_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_an_unratified_and_unpublished_course_i_want_to_edit
    given_a_course_exists(:unpublished)
  end

  def and_there_is_a_unpublished_course_i_want_to_edit
    given_a_course_exists(:unpublished, :with_accrediting_provider)
  end

  def and_there_is_a_second_provider_partnership
    @new_ratifying_provider = create(:accredited_provider) do |accredited_provider|
      create(:provider_partnership, training_provider: provider, accredited_provider:)
    end
  end

  def when_i_visit_the_course_details_page
    publish_courses_details_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: @course.course_code,
    )
  end

  def then_i_see_a_message_to_add_an_ratifying_provider
    expect(page).to have_content("Add at least one accredited provider")
  end

  def then_i_see_a_message_to_select_an_ratifying_provider
    expect(page).to have_content("Select an accredited provider")
  end

  def and_i_click_to_change_the_ratifying_provider
    click_on "Change accredited provider"
  end

  def then_i_do_not_see_a_change_link_for_ratifying_provider
    expect(page).to have_no_content("Change accredited provdier")
  end

  def then_i_can_choose_a_different_accredited_provider
    choose @new_ratifying_provider.provider_name
  end

  def when_i_click_update
    click_on "Update accredited provider"
  end

  def then_i_see_a_success_message
    expect(page).to have_content("Success\nAccredited provider updated")
  end

  def and_i_see_the_ratifying_provider_is_updated
    expect(page).to have_content(/(Accredited|ratifying) provider\s*#{Regexp.escape(@new_ratifying_provider.provider_name)}/i)
  end

  def and_there_is_a_published_course_i_want_to_edit
    given_a_course_exists(:published, :with_accrediting_provider)
  end

  def when_i_visit_the_publish_course_information_edit_page
    visit school_placements_publish_provider_recruitment_cycle_course_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      code: @course.course_code,
    )
  end

  def and_i_submit
    click_on "Update how placements work"
  end

  def and_the_course_information_is_updated
    enrichment = course.reload.enrichments.find_or_initialize_draft

    expect(enrichment.how_school_placements_work).to eq(@school_placements)
  end

  def then_i_see_an_error_message_about_reducing_word_count
    expect(page).to have_content("Reduce the word count for how placements work").twice
  end

  def then_i_see_an_error_message_about_entering_data
    expect(page).to have_content("Enter details about how placements work").twice
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
