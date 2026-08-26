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

private

  attr_reader :support_user

  def given_a_support_user_exists
    @support_user = create(:user, :admin)
  end

  def given_there_is_an_active_support_banner
    @banner = create(:banner, heading: "Support notice", body: "System update pending.", published_at: 1.day.ago, display_on_support: true)
  end

  def when_i_visit_the_support_root
    visit support_root_path
  end

  def then_i_see_the_banner
    expect(page).to have_content("Support notice")
    expect(page).to have_content("System update pending.")
  end
end
