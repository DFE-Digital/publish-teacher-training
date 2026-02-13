require "rails_helper"

RSpec.describe "Support console: providers onboarding form requests - copy link", :js, service: :support, type: :system do
  let(:admin_user) { create(:user, :admin) }

  before do
    given_i_am_an_admin_user
  end

  scenario "copy link action is revealed by JS and provides feedback" do
    given_a_provider_onboarding_form_request_exists
    when_i_visit_the_onboarding_request_page
    then_i_see_the_copy_button
    when_i_click_the_copy_button
    then_the_button_should_say_copied
  end

  scenario "copy link button is NOT visible when JavaScript is disabled" do
    given_a_provider_onboarding_form_request_exists
    and_javascript_is_disabled

    # Button should NOT appear because it's normally revealed by JS
    then_i_do_not_see_the_copy_button
  end

  def given_i_am_an_admin_user
    sign_in_system_test(user: admin_user)
  end

  def given_a_provider_onboarding_form_request_exists
    @request = create(:providers_onboarding_form_request)
  end

  def when_i_visit_the_onboarding_request_page
    visit support_providers_onboarding_form_request_path(@request)
  end

  def then_i_see_the_copy_button
    expect(page).to have_selector(".copy-btn", text: "Copy link", visible: :visible)
  end

  def when_i_click_the_copy_button
    page.driver.with_playwright_page do |pw_page|
      pw_page.context.grant_permissions(%w[clipboard-read clipboard-write])
    end
    @copy_btn = page.find(".copy-btn", match: :first)
    @copy_btn.click
  end

  def then_the_button_should_say_copied
    expect(@copy_btn).to have_text("Copied!")

    using_wait_time 3 do
      expect(@copy_btn).to have_text("Copy link")
    end
  end

  def and_javascript_is_disabled
    using_session(:no_js) do
      Capybara.using_driver(:rack_test) do
        when_i_visit_the_onboarding_request_page
      end
    end
  end

  def then_i_do_not_see_the_copy_button
    expect(page).not_to have_selector(".copy-btn", text: "Copy link")
  end
end
