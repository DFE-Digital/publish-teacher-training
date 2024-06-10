# frozen_string_literal: true

require 'rails_helper'

feature 'Editing fees and financial support section' do
  scenario 'adding valid data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_fees_and_financial_support_edit_page
    then_i_see_markdown_formatting_guidance

    when_i_enter_information_into_the_fees_and_financial_support_field
    and_i_submit_the_form
    then_fees_and_financial_support_data_has_changed

    when_i_visit_the_fees_and_financial_support_edit_page
    then_i_see_the_new_fees_and_financial_support_information
  end

  scenario 'entering invalid data' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_fees_and_financial_support_edit_page
    and_i_enter_too_many_words
    and_i_submit_the_form
    then_i_see_an_error_message
  end

  scenario 'I see the guidance on the page' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_fees_and_financial_support_edit_page
    then_i_see_guidance

    when_i_expand_the_guidance_section
    then_i_see_more_information
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def then_i_see_markdown_formatting_guidance
    page.find('span', text: 'Help formatting your text')
    expect(page).to have_content 'How to format your text'
    expect(page).to have_content 'How to create a link'
    expect(page).to have_content 'How to create bullet points'
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(:fee_type_based, enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_fees_and_financial_support_edit_page
    visit fees_and_financial_support_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    )
  end

  def and_i_submit_the_form
    click_on 'Update fees and financial support'
  end

  def then_i_see_the_new_fees_and_financial_support_information
    expect(find_field('Fees and financial support').value).to eq 'Here is very useful information fees and financial support'
  end

  def then_fees_and_financial_support_data_has_changed
    expect(page).to have_content 'Fees and financial support updated'
    expect(page).to have_content 'Here is very useful information fees and financial support'

    enrichment = course.reload.enrichments.find_or_initialize_draft
    expect(enrichment.fee_details).to eq('Here is very useful information fees and financial support')
  end

  def then_i_see_an_error_message
    expect(page).to have_content('Reduce the word count for fees and financial support').twice
  end

  def and_i_enter_too_many_words
    fill_in 'Fees and financial support', with: Faker::Lorem.sentence(word_count: 251)
  end

  def when_i_enter_information_into_the_fees_and_financial_support_field
    fill_in 'Fees and financial support (optional)', with: 'Here is very useful information fees and financial support'
  end

  def then_i_see_guidance
    expect(page).to have_content 'Candidates find it helpful to know when fees are due, payment schedules, top up fees and other costs like books and transport'
  end

  def when_i_expand_the_guidance_section
    page.find('span', text: 'See what we include in this section').click
  end

  def then_i_see_more_information
    expect(page).to have_content 'Financial support from the government'
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
