# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Viewing feature flags" do
  let(:user) { create(:user, :admin) }

  scenario "I view all feature flags" do
    given_i_am_authenticated
    when_i_navigate_to_the_feature_flags_page
    then_i_see_the_list_of_available_feature_flags
  end

  def given_i_am_authenticated
    sign_in_system_test(user:)
  end

  def when_i_navigate_to_the_feature_flags_page
    visit support_root_path
    click_on "Settings"
    click_on "Feature Flags"
  end

  def then_i_see_the_list_of_available_feature_flags
    [
      "Puts Find into maintenance mode",
      "Displays the maintenance mode banner",
      "Display scholarship and bursary information",
    ].each do |feature_flag_text|
      expect(page).to have_content(feature_flag_text)
    end
  end
end
