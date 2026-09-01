# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Banners on the Publish interface" do
  scenario "active banners are displayed" do
    given_there_is_an_active_publish_banner
    and_i_am_authenticated
    when_i_visit_the_publish_organisations_page
    then_i_see_the_banner
  end

  scenario "banners stay on the page alongside a flash message" do
    given_there_is_an_active_publish_banner
    and_i_am_authenticated
    when_i_update_notification_preferences
    then_i_see_the_banner
    and_i_see_the_flash_message
  end

private

  def given_there_is_an_active_publish_banner
    @banner = create(:banner, body: "Planned downtime.", published_at: 1.day.ago, display_on_publish: true)
  end

  def and_i_am_authenticated
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, sites: [build(:site)], courses: [build(:course)]),
        ],
      ),
    )
  end

  def when_i_visit_the_publish_organisations_page
    visit publish_root_path
  end

  def when_i_update_notification_preferences
    visit publish_notifications_path

    choose "Yes, send me notifications"
    click_link_or_button "Save"
  end

  def then_i_see_the_banner
    expect(page).to have_content("Planned downtime.")
  end

  def and_i_see_the_flash_message
    expect(page).to have_css(".govuk-notification-banner--success")
  end
end
