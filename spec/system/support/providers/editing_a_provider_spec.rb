# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Viewing and editing a provider" do
  let(:user) { create(:user, :admin) }

  before do
    given_i_am_authenticated(user:)
    and_there_is_a_provider
    when_i_visit_the_support_provider_show_page
    then_i_can_view_provider_details
  end

  context "valid details" do
    scenario "I can edit a provider's name (provider detail)" do
      when_i_click_on_the_change_link
      then_i_am_on_the_support_provider_edit_page
      when_i_fill_in_a_valid_provider_name
      and_i_choose_a_different_provider_type
      and_i_fill_in_a_valid_number
      and_i_click_the_submit_button
      then_i_am_redirected_back_to_the_support_provider_show_page
      and_the_provider_details_are_updated
    end
  end

  context "invalid details" do
    scenario "I cannot edit a provider's name (provider detail)" do
      when_i_click_on_the_change_link
      then_i_am_on_the_support_provider_edit_page
      when_i_fill_in_an_invalid_provider_name
      and_i_click_the_submit_button
      then_i_see_the_error_summary
    end
  end

  context "provider code" do
    scenario "I cannot change the provider code after a course has been published" do
      given_the_provider_has_a_withdrawn_course
      when_i_click_on_the_change_link
      then_i_am_on_the_support_provider_edit_page
      and_i_cannot_edit_the_provider_code
    end

    scenario "I can change a provider code" do
      when_i_click_on_the_change_link
      then_i_am_on_the_support_provider_edit_page
      and_i_see_the_provider_code_hint
      when_i_enter_a_provider_code("Z99")
      and_i_click_the_submit_button
      then_i_am_redirected_back_to_the_support_provider_show_page
      and_i_see_the_provider_code_updated_banner("Z99")
      and_the_provider_code_is_shown_as("Z99")
    end

    scenario "I cannot save a provider code that is already in use" do
      given_another_provider_already_uses("Y88")
      when_i_click_on_the_change_link
      when_i_enter_a_provider_code("Y88")
      and_i_click_the_submit_button
      then_i_see_the_provider_code_error("Provider code already in use. Enter a new provider code")
      and_the_stored_provider_code_is_unchanged
    end

    scenario "I see an error when the provider code is not 3 characters" do
      when_i_click_on_the_change_link
      when_i_enter_a_provider_code("Z9")
      and_i_click_the_submit_button
      then_i_see_the_provider_code_error("Provider code must be 3 characters")
    end

    scenario "I see an error when the provider code format is invalid" do
      when_i_click_on_the_change_link
      when_i_enter_a_provider_code("abc")
      and_i_click_the_submit_button
      then_i_see_the_provider_code_error("Enter a valid provider code. It must be exactly 3 characters with at least one number. All letters must be in upper case.")
      and_the_provider_code_field_still_shows("abc")
    end
  end

private

  def and_there_is_a_provider
    @provider = create(:provider, :accredited_provider, :scitt, provider_name: "Provider 1", accredited_provider_number: 5432)
    @original_provider_code = @provider.provider_code
  end

  def provider_table_cell(heading)
    headings = page.all("table.govuk-table thead th").map(&:text)

    page.all("table.govuk-table tbody td")[headings.index(heading)]
  end

  def when_i_visit_the_support_provider_show_page
    support_provider_show_page.load(recruitment_cycle_year: Find::CycleTimetable.current_year, id: @provider.id)
  end

  def then_i_can_view_provider_details
    expect(page).to have_css(
      "h1 a[href='#{publish_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle_year)}']",
      text: @provider.name_and_code,
    )
    expect(page.all("table.govuk-table thead th").map(&:text)).to eq(
      ["Provider name", "Provider code", "Accredited provider number", "UKPRN", "View in Publish"],
    )
    expect(page.find("th", exact_text: "Provider name")[:class]).to include("govuk-!-width-one-quarter")
    expect(page.find("th", exact_text: "Accredited provider number")[:class]).to include("govuk-!-width-one-quarter")
    expect(provider_table_cell("Provider name")).to have_link(
      "Provider 1",
      href: edit_support_recruitment_cycle_provider_path(@provider.recruitment_cycle_year, @provider),
      class: "govuk-!-font-weight-bold",
    )
    expect(provider_table_cell("Provider name")).to have_css("p.govuk-hint", text: "SCITT")
    expect(provider_table_cell("Provider code")).to have_text(@provider.provider_code)
    expect(provider_table_cell("Accredited provider number")).to have_text("5432")
    expect(provider_table_cell("UKPRN")).to have_text(@provider.ukprn)
    expect(provider_table_cell("View in Publish")).to have_link(
      "View provider",
      href: details_publish_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle_year),
    )
  end

  def when_i_click_on_the_change_link
    provider_table_cell("Provider name").click_link("Provider 1")
  end

  def then_i_am_on_the_support_provider_edit_page
    expect(support_provider_edit_page).to be_displayed
  end

  def when_i_fill_in_a_valid_provider_name
    support_provider_edit_page.provider_name.set("Provider 2")
  end

  def and_i_fill_in_a_valid_number
    fill_in "provider-accredited-provider-number-field", with: "1234"
  end

  def and_i_choose_a_different_provider_type
    choose "Higher education institute (HEI)"
  end

  def and_i_click_the_submit_button
    support_provider_edit_page.submit.click
  end

  def then_i_am_redirected_back_to_the_support_provider_show_page
    expect(support_provider_show_page).to be_displayed(id: @provider.id)
  end

  def and_the_provider_details_are_updated
    expect(support_provider_show_page).to have_text("Provider 2")
    expect(support_provider_show_page).to have_text("University")
  end

  def when_i_fill_in_an_invalid_provider_name
    support_provider_edit_page.provider_name.set(SecureRandom.hex(100))
  end

  def then_i_see_the_error_summary
    expect(support_provider_edit_page.error_summary).to be_visible
  end

  def given_the_provider_has_a_withdrawn_course
    create(:course, :withdrawn, provider: @provider)
  end

  def and_i_cannot_edit_the_provider_code
    expect(page).to have_no_field("Provider code")
    expect(page).to have_content(@original_provider_code)
    expect(page).to have_content("You cannot change the provider code because this provider has had a published course. Courses are sent to Apply when they are published and remain available there after they are withdrawn.")
  end

  def and_i_see_the_provider_code_hint
    expect(page).to have_content("Provider code must be exactly 3 characters with at least one number. All letters must be in upper case.")
    expect(page).to have_content("We’ll check that the provider code is valid and is not already in use on Publish for this recruitment cycle.")
  end

  def when_i_enter_a_provider_code(provider_code)
    support_provider_edit_page.provider_code.set(provider_code)
  end

  def given_another_provider_already_uses(provider_code)
    create(:provider, recruitment_cycle: @provider.recruitment_cycle, provider_code:)
  end

  def and_i_see_the_provider_code_updated_banner(provider_code)
    expect(page).to have_css(".govuk-notification-banner__heading", text: "Provider code updated to #{provider_code}")
  end

  def and_the_provider_code_is_shown_as(provider_code)
    expect(provider_table_cell("Provider code")).to have_text(provider_code)
    expect(@provider.reload.provider_code).to eq(provider_code)
  end

  def then_i_see_the_provider_code_error(message)
    expect(page).to have_css(".govuk-error-summary", text: message)
    expect(page).to have_css(".govuk-error-message", text: message)
  end

  def and_the_stored_provider_code_is_unchanged
    expect(@provider.reload.provider_code).to eq(@original_provider_code)
  end

  def and_the_provider_code_field_still_shows(provider_code)
    expect(page).to have_field("Provider code", with: provider_code)
  end
end
