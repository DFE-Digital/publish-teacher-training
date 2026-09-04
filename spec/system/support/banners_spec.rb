# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Banner management support" do
  include DfESignInUserHelper

  before do
    given_a_support_user_exists
    sign_in_system_test(user: support_user)
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
    when_i_visit_the_banners_page(:active)
    and_i_click_add_banner
    then_i_see_the_new_banner_page

    when_i_fill_in_the_banner_form
    and_i_submit_the_form
    then_the_banner_is_created
  end

  scenario "creating a banner with invalid data shows errors" do
    when_i_visit_the_banners_page(:active)
    and_i_click_add_banner
    and_i_submit_the_form
    then_i_see_validation_errors
  end

  scenario "creating a banner with all fields" do
    when_i_visit_the_banners_page(:active)
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

  scenario "taking a banner off one of the interfaces it displays on" do
    given_there_is_an_active_banner
    when_i_visit_the_banners_page(:active)
    and_i_click_edit_on_the_banner

    when_i_uncheck_find
    and_i_submit_the_form
    then_the_banner_no_longer_displays_on_find
  end

  scenario "editing a banner with invalid data shows errors" do
    given_there_is_an_active_banner
    when_i_visit_the_banners_page(:active)
    and_i_click_edit_on_the_banner

    when_i_clear_the_banner_name
    and_i_submit_the_form
    then_i_see_validation_errors
  end

  scenario "deleting a banner nobody has seen" do
    given_there_are_scheduled_banners
    when_i_visit_the_banners_page(:scheduled)
    and_i_click_delete_on_the_first_banner
    and_i_confirm_the_deletion
    then_the_banner_is_deleted
  end

  scenario "delete is not offered once a banner has been published" do
    given_there_are_active_banners
    when_i_visit_the_banners_page(:active)
    then_i_do_not_see_the_delete_action
  end

  scenario "an expired banner offers preview instead of edit" do
    given_there_are_expired_banners
    when_i_visit_the_banners_page(:expired)
    then_the_name_links_to_the_preview
  end

private

  attr_reader :support_user

  def given_a_support_user_exists
    @support_user = create(:user, :admin)
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

  def and_the_active_tab_is_selected
    expect(page).to have_css(".app-tab-navigation__link[aria-current='page']", text: "Active")
  end

  def and_the_scheduled_tab_is_selected
    expect(page).to have_css(".app-tab-navigation__link[aria-current='page']", text: "Scheduled")
  end

  def and_the_expired_tab_is_selected
    expect(page).to have_css(".app-tab-navigation__link[aria-current='page']", text: "Expired")
  end

  def and_i_see_the_active_banners
    @active_banners.each do |banner|
      expect(page).to have_content(banner.name)
    end
    expect(page).to have_css("thead th", text: "Published")
    expect(page).to have_css("thead th", text: "Due to expire")
    expect(page).to have_no_css("thead th", text: "Status")
    expect(page).to have_no_css("thead th", text: "Actions")
  end

  def and_i_see_the_scheduled_banners
    @scheduled_banners.each do |banner|
      expect(page).to have_content(banner.name)
    end
    expect(page).to have_css("thead th", text: "Due to be published")
    expect(page).to have_css("thead th", text: "Due to expire")
    expect(page).to have_css("thead th", text: "Preview banner")
  end

  def and_i_see_the_expired_banners
    @expired_banners.each do |banner|
      expect(page).to have_content(banner.name)
    end
    expect(page).to have_no_css("thead th", text: "Actions")
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
    fill_in "Body", with: "The service will be unavailable on Saturday."

    publish_on = 1.month.from_now

    within_fieldset("Publish date and time") do
      fill_in "Day", with: publish_on.day
      fill_in "Month", with: publish_on.month
      fill_in "Year", with: publish_on.year
      fill_in "Hour", with: "9"
      fill_in "Minute", with: "0"
    end

    within_fieldset("Displayed on") do
      check "Find"
      check "Publish"
    end
  end

  def and_i_submit_the_form
    click_link_or_button "Continue"
  end

  def then_the_banner_is_created
    expect(page).to have_current_path(scheduled_support_banners_path, ignore_query: true)

    banner = Banner.last
    expect(banner.name).to eq("Important maintenance notice")
    expect(banner.body).to eq("The service will be unavailable on Saturday.")
    expect(banner.display_on_find).to be(true)
    expect(banner.display_on_publish).to be(true)
    expect(banner.display_on_support).to be_falsey
  end

  def when_i_fill_in_all_banner_fields
    fill_in "Name", with: "Full banner"
    fill_in "Heading (optional)", with: "Service update"
    fill_in "Body", with: "Please be aware of upcoming changes."

    within_fieldset("Publish date and time") do
      fill_in "Day", with: "1"
      fill_in "Month", with: "6"
      fill_in "Year", with: "2026"
      fill_in "Hour", with: "9"
      fill_in "Minute", with: "30"
    end

    within_fieldset("Expiry date and time") do
      fill_in "Day", with: "30"
      fill_in "Month", with: "6"
      fill_in "Year", with: "2026"
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
      click_link_or_button @active_banner.name
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

  def when_i_uncheck_find
    within_fieldset("Displayed on") do
      uncheck "Find"
    end
  end

  def then_the_banner_no_longer_displays_on_find
    expect(page).to have_current_path(active_support_banners_path, ignore_query: true)
    expect(@active_banner.reload.display_on_find).to be(false)
  end

  def and_i_click_delete_on_the_first_banner
    within("tr", text: @scheduled_banners.first.name) do
      click_link_or_button "Delete"
    end
  end

  def and_i_confirm_the_deletion
    click_link_or_button "Delete banner"
  end

  def then_the_banner_is_deleted
    expect(page).to have_current_path(scheduled_support_banners_path, ignore_query: true)
    expect(Banner.where(id: @scheduled_banners.first.id)).to be_empty
  end

  def then_i_do_not_see_the_delete_action
    expect(page).to have_no_link("Delete")
  end

  def then_the_name_links_to_the_preview
    banner = @expired_banners.first
    within("tr", text: banner.name) do
      expect(page).to have_link(banner.name, href: support_banner_path(banner))
    end
  end

  def when_i_clear_the_banner_name
    fill_in "Name", with: ""
  end

  def then_i_see_validation_errors
    expect(page).to have_css(".govuk-error-summary")
  end
end
