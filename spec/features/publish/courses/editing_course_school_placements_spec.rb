# frozen_string_literal: true

require "rails_helper"

feature "Editing how placements work" do
  scenario "I can update some information about the course" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_publish_course_information_edit_page
    then_i_see_markdown_formatting_guidance

    when_i_enter_school_placements_information
    and_i_submit
    then_i_see_a_success_message
    and_the_course_information_is_updated
  end

  scenario "I see errors when updating with invalid data" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_publish_course_information_edit_page
    and_i_submit_with_too_many_words
    then_i_see_an_error_message_about_reducing_word_count

    and_i_submit_without_any_data
    then_i_see_an_error_message_about_entering_data
  end

  scenario "I can view additional guidance for this section when provider has selectable school toggle active" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    and_school_placement_is_selectable
    when_i_visit_the_publish_course_information_edit_page
    and_i_click_to_see_more_guidance
    then_i_see_selectable_school_placement_guidance
  end

  scenario "I can view additional guidance for this section when course is salaried" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_salaried_course_i_want_to_edit
    and_school_placement_is_not_selectable
    when_i_visit_the_publish_course_information_edit_page
    and_i_click_to_see_more_guidance
    then_i_see_salaried_course_school_placement_guidance
  end

  scenario "I can view additional guidance for this section when course is fee based" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_fee_based_course_i_want_to_edit
    and_school_placement_is_not_selectable
    when_i_visit_the_publish_course_information_edit_page
    and_i_click_to_see_more_guidance
    then_i_see_fee_based_course_school_placement_guidance
  end

private

  def and_i_click_to_see_more_guidance
    page.find("span", text: "See what we include in this section").click
  end

  def then_i_see_markdown_formatting_guidance
    page.find("span", text: "How to create links and bullet points")
    expect(page).to have_content "How to create a link"
    expect(page).to have_content "How to create bullet points"
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(:published)
  end

  def and_there_is_a_fee_based_course_i_want_to_edit
    given_a_course_exists(:fee, :published)
  end

  def and_there_is_a_salaried_course_i_want_to_edit
    given_a_course_exists(:salary, :published)
  end

  def and_school_placement_is_selectable
    @course.provider.update!(selectable_school: true)
  end

  def and_school_placement_is_not_selectable
    @course.provider.update!(selectable_school: false)
  end

  def then_i_see_the_reuse_content
    expect(publish_course_information_edit_page).to have_use_content
  end

  def when_i_visit_the_publish_course_information_edit_page
    visit school_placements_publish_provider_recruitment_cycle_course_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      code: @course.course_code,
    )
  end

  def when_i_enter_school_placements_information
    @school_placements = "This is a new school placements"

    fill_in "How placements work", with: @school_placements
  end

  def and_i_submit_with_too_many_words
    fill_in "How placements work", with: Faker::Lorem.sentence(word_count: 351)
    and_i_submit
  end

  def and_i_submit_without_any_data
    fill_in "How placements work", with: ""
    and_i_submit
  end

  def and_i_submit
    click_on "Update how placements work"
  end

  def then_i_see_a_success_message
    expect(page).to have_content "How placements work updated"
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

  def then_i_see_selectable_school_placement_guidance
    expect(page).to have_content(
      "The training provider will contact you to discuss your preferences, to help them select placement schools you can travel to.",
    )
    expect(page).to have_content("Find out more about where your school placements will take place.")
  end

  def then_i_see_salaried_course_school_placement_guidance
    expect(page).to have_content(
      "The training provider will contact you to discuss your preferences, to help them select placement schools you can travel to.",
    )
    expect(page).to have_content("Find out more about where your school placements will take place.")
  end

  def then_i_see_fee_based_course_school_placement_guidance
    expect(page).to have_content(
      "The training provider will contact you to discuss your preferences, to help them select placement schools you can travel to.",
    )
    expect(page).to have_content("Find out more about where your school placements will take place.")
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
