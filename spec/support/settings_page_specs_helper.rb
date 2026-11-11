# frozen_string_literal: true

module SettingsPageSpecsHelper
  def given_i_visit_the_support_settings_page
    visit support_settings_path
  end

  def then_i_see_the_backlink_to_the_settings_page
    expect(page).to have_link("Back", href: support_settings_path)
  end

  def then_i_click_back_button
    click_link_or_button "Back"
  end

  def then_i_am_on_the_settings_page
    expect(page).to have_current_path(support_settings_path)
  end
end
