# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support settings navigation", service: :support do
  let(:user) { create(:user, :admin) }

  before do
    sign_in_system_test(user:)
    visit support_settings_path
  end

  scenario "displays links to support pages grouped under Settings" do
    expect(page).to have_link(
      "Financial incentives",
      href: support_financial_incentives_path,
    )

    expect(page).to have_link(
      "Feedback",
      href: support_feedback_index_path,
    )

    expect(page).to have_link(
      "Subject synonyms",
      href: support_subjects_path,
    )
  end
end
