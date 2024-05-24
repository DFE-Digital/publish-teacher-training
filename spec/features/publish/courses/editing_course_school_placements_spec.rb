# frozen_string_literal: true

require 'rails_helper'

feature 'Editing how school placements work', { can_edit_current_and_next_cycles: false } do
  scenario 'I can update some information about the course' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_publish_course_information_edit_page
    and_i_set_information_about_the_course
    and_i_submit
    then_i_see_a_success_message
    and_the_course_information_is_updated
  end

  scenario 'I see errors when updating with invalid data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_publish_course_information_edit_page
    and_i_submit_with_too_many_words
    then_i_see_an_error_message_about_reducing_word_count

    and_i_submit_without_any_data
    then_i_see_an_error_message_about_entering_data
  end

  scenario 'I can view additional guidance for this section as a university provider' do
    given_i_am_authenticated_as_a_university_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_publish_course_information_edit_page
    and_i_click_to_see_more_guidance
    then_i_see_the_message_for_university_users
  end

  scenario 'I can view additional guidance for this section as a scitt provider' do
    given_i_am_authenticated_as_a_scitt_provider_user
    and_there_is_a_scitt_course_i_want_to_edit
    when_i_visit_the_publish_course_information_edit_page
    and_i_click_to_see_more_guidance
    then_i_see_the_message_for_scitt_users
  end

  private

  def and_i_click_to_see_more_guidance
    page.find('span', text: 'See what we include in this section').click
  end

  def then_i_see_the_message_for_university_users
    expect(page).to have_content 'Where you will train'
    expect(page).to have_content 'Universities can work with over 100 potential placement schools.'
  end

  def then_i_see_the_message_for_scitt_users
    expect(page).to have_content 'Where you will train'
    expect(page).to have_no_content 'Universities can work with over 100 potential placement schools.'
    expect(page).to have_content 'You will be placed in different schools during your training.'
  end

  def given_i_am_authenticated_as_a_university_provider_user
    given_i_am_authenticated(user: create(:user, :with_university_provider))
  end

  def given_i_am_authenticated_as_a_scitt_provider_user
    given_i_am_authenticated(user: create(:user, :with_scitt_provider))
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_scitt_course_i_want_to_edit
    given_a_course_exists(program_type: :scitt_programme, enrichments: [build(:course_enrichment, :published)])
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def then_i_see_the_reuse_content
    expect(publish_course_information_edit_page).to have_use_content
  end

  def when_i_visit_the_publish_course_information_edit_page
    visit school_placements_publish_provider_recruitment_cycle_course_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      code: @course.course_code
    )
  end

  def and_i_set_information_about_the_course
    @school_placements = 'This is a new school placements'

    fill_in 'How school placements work', with: @school_placements
  end

  def and_i_submit_with_too_many_words
    fill_in 'How school placements work', with: Faker::Lorem.sentence(word_count: 351)
    and_i_submit
  end

  def and_i_submit_without_any_data
    fill_in 'How school placements work', with: ''
    and_i_submit
  end

  def and_i_submit
    click_on 'Update how school placements work'
  end

  def then_i_see_a_success_message
    expect(page).to have_content 'How school placements work updated'
  end

  def and_the_course_information_is_updated
    enrichment = course.reload.enrichments.find_or_initialize_draft

    expect(enrichment.how_school_placements_work).to eq(@school_placements)
  end

  def then_i_see_an_error_message_about_reducing_word_count
    expect(page).to have_content('Reduce the word count for how school placements work').twice
  end

  def then_i_see_an_error_message_about_entering_data
    expect(page).to have_content('Enter details about how school placements work').twice
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
