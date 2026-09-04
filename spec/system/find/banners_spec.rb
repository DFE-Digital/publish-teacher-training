# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Banners on the Find interface", service: :find do
  scenario "active banners are displayed" do
    given_there_is_an_active_find_banner
    when_i_visit_the_find_homepage
    then_i_see_the_banner
  end

private

  def given_there_is_an_active_find_banner
    @banner = create(:banner, body: "Maintenance this weekend.", published_at: 1.day.ago, display_on_find: true)
  end

  def when_i_visit_the_find_homepage
    visit find_root_path
  end

  def then_i_see_the_banner
    expect(page).to have_content("Maintenance this weekend.")
  end
end
