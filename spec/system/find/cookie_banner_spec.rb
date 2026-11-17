# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cookie banner on Find", service: :find do
  before do
    allow(Rails.env).to receive(:production?).and_return(true)
  end

  scenario "accepting analytics cookies loads Clarity with consent" do
    given_the_cookie_banner_is_switched_on
    when_i_visit_the_find_homepage
    then_i_see_the_cookie_banner
    and_clarity_is_not_loaded

    when_i_accept_analytics_cookies
    then_i_see_i_have_accepted_analytics_cookies
    and_clarity_is_loaded_with_consent

    when_i_hide_the_cookie_message
    then_i_do_not_see_the_cookie_banner
    and_clarity_is_loaded_with_consent
  end

  scenario "rejecting analytics cookies keeps Clarity off" do
    given_the_cookie_banner_is_switched_on
    when_i_visit_the_find_homepage
    and_i_reject_analytics_cookies
    then_i_see_i_have_rejected_analytics_cookies
    and_clarity_is_not_loaded

    when_i_visit_the_find_homepage
    then_i_do_not_see_the_cookie_banner
    and_clarity_is_not_loaded
  end

  scenario "changing my choice on the cookies page" do
    given_the_cookie_banner_is_switched_on
    when_i_visit_the_cookies_page
    then_i_do_not_see_the_cookie_banner
    and_i_see_the_clarity_cookies_listed
    and_analytics_cookies_are_not_chosen

    when_i_choose_to_accept_analytics_cookies_and_save
    then_i_see_my_cookie_settings_are_saved
    and_clarity_is_loaded_with_consent

    when_i_choose_to_reject_analytics_cookies_and_save
    then_clarity_is_not_loaded
  end

  scenario "with the cookie banner switched off Clarity loads as before" do
    when_i_visit_the_find_homepage
    then_i_do_not_see_the_cookie_banner
    and_clarity_is_loaded_without_a_consent_signal
  end

private

  def given_the_cookie_banner_is_switched_on
    FeatureFlag.activate(:find_analytics_consent)
  end

  def when_i_visit_the_find_homepage
    visit find_root_path
  end

  def when_i_visit_the_cookies_page
    visit find_cookies_path
  end

  def then_i_see_the_cookie_banner
    expect(page).to have_css("h2", text: "Cookies on Find teacher training courses")
    expect(page).to have_link("View cookies", href: find_cookies_path)
  end

  def then_i_do_not_see_the_cookie_banner
    expect(page).to have_no_css("h2", text: "Cookies on Find teacher training courses")
    expect(page).to have_no_button("Hide cookie message")
  end

  def when_i_accept_analytics_cookies
    click_on "Accept analytics cookies"
  end

  def and_i_reject_analytics_cookies
    click_on "Reject analytics cookies"
  end

  def then_i_see_i_have_accepted_analytics_cookies
    expect(page).to have_content("You’ve accepted analytics cookies. You can change your cookie settings at any time.")
    expect(page).to have_link("change your cookie settings", href: find_cookies_path)
    expect(page).to have_button("Hide cookie message")
    expect(page).to have_current_path(find_root_path)
  end

  def then_i_see_i_have_rejected_analytics_cookies
    expect(page).to have_content("You’ve rejected analytics cookies. You can change your cookie settings at any time.")
  end

  def when_i_hide_the_cookie_message
    click_on "Hide cookie message"
  end

  def and_i_see_the_clarity_cookies_listed
    within("table", text: "Microsoft Clarity cookies") do
      expect(page).to have_content("_clck").and have_content("_clsk").and have_content("MUID")
    end
  end

  def and_analytics_cookies_are_not_chosen
    expect(page).to have_checked_field("No")
  end

  def when_i_choose_to_accept_analytics_cookies_and_save
    choose "Yes"
    click_on "Save cookie settings"
  end

  def when_i_choose_to_reject_analytics_cookies_and_save
    choose "No"
    click_on "Save cookie settings"
  end

  def then_i_see_my_cookie_settings_are_saved
    expect(page).to have_content("You’ve set your cookie preferences.")
    expect(page).to have_checked_field("Yes")
  end

  def and_clarity_is_loaded_with_consent
    expect(page).to have_css("script[src*='find/clarity'][data-analytics-consent='granted']", visible: :all)
  end

  def and_clarity_is_loaded_without_a_consent_signal
    expect(page).to have_css("script[src*='find/clarity']:not([data-analytics-consent])", visible: :all)
  end

  def and_clarity_is_not_loaded
    expect(page).to have_no_css("script[src*='find/clarity']", visible: :all)
  end

  alias_method :then_clarity_is_not_loaded, :and_clarity_is_not_loaded
end
