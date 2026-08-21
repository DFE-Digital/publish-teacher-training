# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Banners on the Support interface" do
  include DfESignInUserHelper

  before do
    given_a_support_user_exists
    sign_in_system_test(user: support_user)
  end

  scenario "active banners are displayed" do
    given_there_is_an_active_support_banner
    when_i_visit_the_support_root
    then_i_see_the_banner
  end

  scenario "banners are not displayed when there is a flash message" do
    given_there_is_an_active_support_banner
    and_there_is_another_active_banner_to_expire
    when_i_visit_the_active_banners_page
    and_i_expire_the_other_banner
    then_i_do_not_see_the_layout_banner
  end

private

  attr_reader :support_user

  def given_a_support_user_exists
    @support_user = create(:user, :admin)
  end

  def given_there_is_an_active_support_banner
    @banner = create(:banner, title: "Important", heading: "Support notice", body: "System update pending.", published_at: 1.day.ago, display_on_support: true)
  end

  def and_there_is_another_active_banner_to_expire
    @expirable_banner = create(:banner, name: "Expirable banner", published_at: 1.day.ago, expired_at: nil, display_on_support: false)
  end

  def when_i_visit_the_support_root
    visit support_root_path
  end

  def when_i_visit_the_active_banners_page
    visit active_support_banners_path
  end

  def and_i_expire_the_other_banner
    within("tr", text: @expirable_banner.name) do
      click_link_or_button "Expire"
    end
  end

  def then_i_see_the_banner
    expect(page).to have_content("Support notice")
    expect(page).to have_content("System update pending.")
  end

  def then_i_do_not_see_the_layout_banner
    expect(page).to have_content("Banner was successfully expired.")
    expect(page).to have_no_content("Support notice")
  end
end
