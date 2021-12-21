# frozen_string_literal: true

require "rails_helper"

feature "View provider users" do
  let(:user) { create(:user, :admin) }

  before do
    given_i_am_authenticated(user: user)
    and_there_is_a_provider
    when_i_visit_the_provider_show_page
    then_i_can_view_provider_details
    when_i_click_on_the_change_link
    then_i_am_on_the_provider_edit_page
  end

  context "valid details" do
    scenario "I can edit a provider's name" do
      when_i_fill_in_a_valid_provider_name
      and_i_choose_a_different_provider_type
      and_i_click_the_submit_button
      then_i_am_redirected_back_to_the_provider_show_page
      and_the_provider_details_are_updated
    end
  end

  context "invalid details" do
    scenario "I cannot edit a provider's name" do
      when_i_fill_in_an_invalid_provider_name
      and_i_click_the_submit_button
      then_i_see_the_error_summary
    end
  end

private

  def and_there_is_a_provider
    @provider = create(:provider, provider_name: "Provider 1", provider_type: "scitt", accrediting_provider: "accredited_body")
  end

  def when_i_visit_the_provider_show_page
    provider_show_page.load(id: @provider.id)
  end

  def then_i_can_view_provider_details
    expect(provider_show_page).to have_text("Provider 1")
    expect(provider_show_page).to have_text("Yes")
    expect(provider_show_page).to have_text("SCITT")
  end

  def when_i_click_on_the_change_link
    click_link "Change provider name"
  end

  def then_i_am_on_the_provider_edit_page
    provider_edit_page.load(id: @provider.id)
  end

  def when_i_fill_in_a_valid_provider_name
    provider_edit_page.provider_name.set("Provider 2")
  end

  def and_i_choose_a_different_provider_type
    choose "Lead school"
  end

  def and_i_click_the_submit_button
    provider_edit_page.submit.click
  end

  def then_i_am_redirected_back_to_the_provider_show_page
    expect(provider_show_page).to be_displayed(id: @provider.id)
  end

  def and_the_provider_details_are_updated
    expect(provider_show_page).to have_text("Provider 2")
    expect(provider_show_page).to have_text("No")
    expect(provider_show_page).to have_text("Lead school")
  end

  def when_i_fill_in_an_invalid_provider_name
    provider_edit_page.provider_name.set(SecureRandom.hex(100))
  end

  def then_i_see_the_error_summary
    expect(provider_edit_page.error_summary).to be_visible
  end
end
