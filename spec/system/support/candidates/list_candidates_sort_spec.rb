require "rails_helper"

RSpec.describe "Support console Candidates sorting" do
  let(:user) { create(:user, :admin) }

  before { sign_in_system_test(user:) }

  scenario "toggle Created at sorts between newest and oldest" do
    older = create(:candidate, created_at: 3.days.ago)
    create(:candidate, created_at: 2.days.ago)
    newer = create(:candidate, created_at: 1.day.ago)

    visit support_candidates_path

    click_link "Created at"
    within("table") do
      expect(page).to have_selector("tbody tr:first-child td", text: newer.email_address)
      expect(page).to have_selector("tbody tr:last-child td", text: older.email_address)
    end

    click_link "Created at"
    within("table") do
      expect(page).to have_selector("tbody tr:first-child td", text: older.email_address)
      expect(page).to have_selector("tbody tr:last-child td", text: newer.email_address)
    end
  end
end
