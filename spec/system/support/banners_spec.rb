# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Banner management support" do
  include DfESignInUserHelper

  before do
    given_a_support_user_exists
    sign_in_system_test(user: support_user)
  end

  scenario "viewing draft banners" do
    given_there_are_draft_banners
    when_i_visit_the_banners_page(:drafts)
    then_i_see_the_banners_page
    and_the_draft_tab_is_selected
    and_i_see_the_draft_banners
  end

  scenario "viewing active banners" do
    given_there_are_active_banners
    when_i_visit_the_banners_page(:active)
    then_i_see_the_banners_page
    and_the_active_tab_is_selected
    and_i_see_the_active_banners
  end

  scenario "viewing scheduled banners" do
    given_there_are_scheduled_banners
    when_i_visit_the_banners_page(:scheduled)
    then_i_see_the_banners_page
    and_the_scheduled_tab_is_selected
    and_i_see_the_scheduled_banners
  end

  scenario "viewing expired banners" do
    given_there_are_expired_banners
    when_i_visit_the_banners_page(:expired)
    then_i_see_the_banners_page
    and_the_expired_tab_is_selected
    and_i_see_the_expired_banners
  end

  scenario "creating a new banner" do
    when_i_visit_the_banners_page(:drafts)
    and_i_click_add_banner
    then_i_see_the_new_banner_page

    when_i_fill_in_the_banner_form
    and_i_submit_the_form
    then_the_banner_is_created
  end

  scenario "creating a banner with invalid data shows errors" do
    when_i_visit_the_banners_page(:drafts)
    and_i_click_add_banner
    and_i_submit_the_form
    then_i_see_validation_errors
  end

  scenario "creating a banner with all fields" do
    when_i_visit_the_banners_page(:drafts)
    and_i_click_add_banner
    then_i_see_the_new_banner_page

    when_i_fill_in_all_banner_fields
    and_i_submit_the_form
    then_the_full_banner_is_created
  end

  scenario "editing a banner" do
    given_there_is_an_active_banner
    when_i_visit_the_banners_page(:active)
    and_i_click_edit_on_the_banner
    then_i_see_the_edit_banner_page

    when_i_update_the_banner_name
    and_i_submit_the_form
    then_the_banner_name_is_updated
  end

  scenario "editing a banner with invalid data shows errors" do
    given_there_is_an_active_banner
    when_i_visit_the_banners_page(:active)
    and_i_click_edit_on_the_banner

    when_i_clear_the_banner_name
    and_i_submit_the_form
    then_i_see_validation_errors
  end

  scenario "expiring an active banner" do
    given_there_is_an_active_banner
    when_i_visit_the_banners_page(:active)
    and_i_click_expire_on_the_banner
    then_the_banner_is_expired
    and_the_banner_is_no_longer_on_the_active_tab
    and_the_banner_appears_on_the_expired_tab
  end

  scenario "expire action is only shown for active banners" do
    given_there_are_draft_banners
    when_i_visit_the_banners_page(:drafts)
    then_i_do_not_see_the_expire_action
  end

  scenario "publishing a scheduled banner" do
    given_there_is_a_scheduled_banner
    when_i_visit_the_banners_page(:scheduled)
    and_i_click_publish_on_the_banner
    then_the_banner_is_published
    and_the_banner_is_no_longer_on_the_scheduled_tab
    and_the_banner_appears_on_the_active_tab
  end

  scenario "publish action is only shown for scheduled banners" do
    given_there_are_active_banners
    when_i_visit_the_banners_page(:active)
    then_i_do_not_see_the_publish_action
  end

private

  attr_reader :support_user

  def given_a_support_user_exists
    @support_user = create(:user, :admin)
  end

  def given_there_are_draft_banners
    @draft_banners = create_list(:banner, 2, published_at: nil)
  end

  def given_there_are_active_banners
    @active_banners = [
      create(:banner, name: "Active banner one", published_at: 1.day.ago, expired_at: 1.day.from_now),
      create(:banner, name: "Active banner two", published_at: 2.days.ago, expired_at: nil),
    ]
  end

  def given_there_are_scheduled_banners
    @scheduled_banners = [
      create(:banner, name: "Scheduled banner one", published_at: 1.day.from_now),
      create(:banner, name: "Scheduled banner two", published_at: 2.days.from_now),
    ]
  end

  def given_there_are_expired_banners
    @expired_banners = [
      create(:banner, name: "Expired banner one", published_at: 3.days.ago, expired_at: 1.day.ago),
      create(:banner, name: "Expired banner two", published_at: 5.days.ago, expired_at: 2.days.ago),
    ]
  end

  def given_there_is_an_active_banner
    @active_banner = create(:banner, name: "Banner to edit", published_at: 1.day.ago, expired_at: 1.day.from_now, display_on_find: true)
  end

  def when_i_visit_the_banners_page(status)
    visit send(:"#{status}_support_banners_path")
  end

  def then_i_see_the_banners_page
    expect(page).to have_content("Banners")
  end

  def and_the_draft_tab_is_selected
    expect(page).to have_css(".govuk-tabs__list-item--selected", text: "Draft")
  end

  def and_the_active_tab_is_selected
    expect(page).to have_css(".govuk-tabs__list-item--selected", text: "Active")
  end

  def and_the_scheduled_tab_is_selected
    expect(page).to have_css(".govuk-tabs__list-item--selected", text: "Scheduled")
  end

  def and_the_expired_tab_is_selected
    expect(page).to have_css(".govuk-tabs__list-item--selected", text: "Expired")
  end

  def and_i_see_the_draft_banners
    @draft_banners.each do |banner|
      expect(page).to have_content(banner.name)
    end
    expect(page).to have_css(".govuk-tag", text: "Draft", count: @draft_banners.size)
  end

  def and_i_see_the_active_banners
    @active_banners.each do |banner|
      expect(page).to have_content(banner.name)
    end
    expect(page).to have_css(".govuk-tag", text: "Active", count: @active_banners.size)
  end

  def and_i_see_the_scheduled_banners
    @scheduled_banners.each do |banner|
      expect(page).to have_content(banner.name)
    end
    expect(page).to have_css(".govuk-tag", text: "Scheduled", count: @scheduled_banners.size)
  end

  def and_i_see_the_expired_banners
    @expired_banners.each do |banner|
      expect(page).to have_content(banner.name)
    end
    expect(page).to have_css(".govuk-tag", text: "Expired", count: @expired_banners.size)
  end

  def and_i_click_add_banner
    click_link_or_button "Add banner"
  end

  def then_i_see_the_new_banner_page
    expect(page).to have_content("Add banner")
    expect(page).to have_content("Banner details")
  end

  def when_i_fill_in_the_banner_form
    fill_in "Name", with: "Important maintenance notice"
    fill_in "Title", with: "Service notice"
    fill_in "Heading", with: "Planned maintenance"
    fill_in "Body", with: "The service will be unavailable on Saturday."

    within_fieldset("Displayed on") do
      check "Find"
      check "Publish"
    end
  end

  def and_i_submit_the_form
    click_link_or_button "Continue"
  end

  def then_the_banner_is_created
    expect(page).to have_current_path(drafts_support_banners_path, ignore_query: true)

    banner = Banner.last
    expect(banner.name).to eq("Important maintenance notice")
    expect(banner.title).to eq("Service notice")
    expect(banner.heading).to eq("Planned maintenance")
    expect(banner.body).to eq("The service will be unavailable on Saturday.")
    expect(banner.display_on_find).to be(true)
    expect(banner.display_on_publish).to be(true)
    expect(banner.display_on_support).to be_falsey
  end

  def when_i_fill_in_all_banner_fields
    fill_in "Name", with: "Full banner"
    fill_in "Title", with: "Important notice"
    fill_in "Title heading level", with: "3"
    check "Success styling"
    fill_in "Heading", with: "Service update"
    fill_in "Body", with: "Please be aware of upcoming changes."

    within_fieldset("Publish date") do
      fill_in "Day", with: "1"
      fill_in "Month", with: "6"
      fill_in "Year", with: "2026"
    end

    within_fieldset("Publish time") do
      fill_in "Hour", with: "9"
      fill_in "Minute", with: "30"
    end

    within_fieldset("Expiry date") do
      fill_in "Day", with: "30"
      fill_in "Month", with: "6"
      fill_in "Year", with: "2026"
    end

    within_fieldset("Expiry time") do
      fill_in "Hour", with: "17"
      fill_in "Minute", with: "0"
    end

    within_fieldset("Displayed on") do
      check "Find"
      check "Publish"
      check "Support"
    end
  end

  def then_the_full_banner_is_created
    expect(page).to have_current_path(expired_support_banners_path, ignore_query: true)

    banner = Banner.last
    expect(banner.name).to eq("Full banner")
    expect(banner.title).to eq("Important notice")
    expect(banner.title_heading_level).to eq(3)
    expect(banner.success_styling).to be(true)
    expect(banner.heading).to eq("Service update")
    expect(banner.body).to eq("Please be aware of upcoming changes.")
    expect(banner.published_at).to eq(Time.zone.local(2026, 6, 1, 9, 30))
    expect(banner.expired_at).to eq(Time.zone.local(2026, 6, 30, 17, 0))
    expect(banner.display_on_find).to be(true)
    expect(banner.display_on_publish).to be(true)
    expect(banner.display_on_support).to be(true)
  end

  def and_i_click_edit_on_the_banner
    within("tr", text: @active_banner.name) do
      click_link_or_button "Edit"
    end
  end

  def then_i_see_the_edit_banner_page
    expect(page).to have_content("Edit banner")
    expect(page).to have_content("Banner details")
  end

  def when_i_update_the_banner_name
    fill_in "Name", with: "Updated banner name"
  end

  def then_the_banner_name_is_updated
    expect(page).to have_current_path(active_support_banners_path, ignore_query: true)
    expect(@active_banner.reload.name).to eq("Updated banner name")
  end

  def and_i_click_expire_on_the_banner
    within("tr", text: @active_banner.name) do
      click_link_or_button "Expire"
    end
  end

  def then_the_banner_is_expired
    expect(page).to have_current_path(expired_support_banners_path, ignore_query: true)
    expect(@active_banner.reload.expired_at).to be_present
  end

  def and_the_banner_is_no_longer_on_the_active_tab
    visit active_support_banners_path
    expect(page).to have_no_content(@active_banner.name)
  end

  def and_the_banner_appears_on_the_expired_tab
    visit expired_support_banners_path
    expect(page).to have_content(@active_banner.name)
    expect(page).to have_css(".govuk-tag", text: "Expired")
  end

  def then_i_do_not_see_the_expire_action
    expect(page).to have_no_button("Expire")
  end

  def given_there_is_a_scheduled_banner
    @scheduled_banner = create(:banner, name: "Banner to publish", published_at: 1.day.from_now, expired_at: 2.days.from_now)
  end

  def and_i_click_publish_on_the_banner
    within("tr", text: @scheduled_banner.name) do
      click_link_or_button "Publish"
    end
  end

  def then_the_banner_is_published
    expect(page).to have_current_path(active_support_banners_path, ignore_query: true)
    expect(@scheduled_banner.reload.published_at).to be <= Time.current
  end

  def and_the_banner_is_no_longer_on_the_scheduled_tab
    visit scheduled_support_banners_path
    expect(page).to have_no_content(@scheduled_banner.name)
  end

  def and_the_banner_appears_on_the_active_tab
    visit active_support_banners_path
    expect(page).to have_content(@scheduled_banner.name)
    expect(page).to have_css(".govuk-tag", text: "Active")
  end

  def then_i_do_not_see_the_publish_action
    expect(page).to have_no_button("Publish")
  end

  def when_i_clear_the_banner_name
    fill_in "Name", with: ""
  end

  def then_i_see_validation_errors
    expect(page).to have_css(".govuk-error-summary")
  end
end
