# frozen_string_literal: true

require "rails_helper"

feature "Editing fees and financial support section" do
  scenario "adding valid data" do
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

  scenario "entering invalid data" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_fees_and_financial_support_edit_page
    and_i_enter_too_many_words
    and_i_submit_the_form
    then_i_see_an_error_message
  end

private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def then_i_see_markdown_formatting_guidance
    page.find("span", text: "How to create links and bullet points")
    expect(page).to have_content "How to create a link"
    expect(page).to have_content "How to create bullet points"
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(funding: "fee", enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_fees_and_financial_support_edit_page
    visit fields_fees_and_financial_support_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code,
    )
  end

  def and_i_submit_the_form
    click_on "Update fees and financial support"
  end

  def then_i_see_the_new_fees_and_financial_support_information
    expect(find_field("When are the fees due? Is there a payment schedule? (optional)").value).to eq "fee schedule"
    expect(find_field("Are there any additional fees or costs? (optional)").value).to eq "additional fees"
    expect(find_field("Does your organisation offer any financial support? (optional)").value).to eq "financial support"
  end

  def then_fees_and_financial_support_data_has_changed
    expect(page).to have_content "Fees and financial support updated"
    expect(page).to have_content "fee schedule"
    expect(page).to have_content "additional fees"
    expect(page).to have_content "financial support"

    enrichment = course.reload.enrichments.find_or_initialize_draft
    expect(enrichment.fee_schedule).to eq("fee schedule")
    expect(enrichment.additional_fees).to eq("additional fees")
    expect(enrichment.financial_support).to eq("financial support")
  end

  def then_i_see_an_error_message
    expect(page).to have_content("Fee schedule must be 50 words or less")
    expect(page).to have_content("Additional fees must be 50 words or less")
    expect(page).to have_content("Financial support must be 50 words or less")
  end

  def and_i_enter_too_many_words
    fill_in "When are the fees due? Is there a payment schedule? (optional)", with: Faker::Lorem.sentence(word_count: 51)
    fill_in "Are there any additional fees or costs? (optional)", with: Faker::Lorem.sentence(word_count: 51)
    fill_in "Does your organisation offer any financial support? (optional)", with: Faker::Lorem.sentence(word_count: 51)
  end

  def when_i_enter_information_into_the_fees_and_financial_support_field
    fill_in "When are the fees due? Is there a payment schedule? (optional)", with: "fee schedule"
    fill_in "Are there any additional fees or costs? (optional)", with: "additional fees"
    fill_in "Does your organisation offer any financial support? (optional)", with: "financial support"
  end

  def then_i_see_guidance
    expect(page).to have_content "Candidates find it helpful to know when fees are due, payment schedules, top up fees and other costs like books and transport"
  end

  def when_i_expand_the_guidance_section
    page.find("span", text: "See what we include in this section").click
  end

  def then_i_see_more_information
    expect(page).to have_content "Financial support from the government"
  end

  def provider
    @provider ||= @current_user.providers.first
  end
end
