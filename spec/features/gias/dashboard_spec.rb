require "rails_helper"

RSpec.feature "viewing dashboard" do
  scenario "user not authenticated" do
    visit "/gias"

    expect(page.current_path).to eq "/sign-in"
  end
end
