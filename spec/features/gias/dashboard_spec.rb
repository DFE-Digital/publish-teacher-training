require "rails_helper"

RSpec.feature "viewing dashboard" do
  scenario "user not authenticated" do
    visit "/gias"

    expect(page.status_code).to eq 302
  end
end
