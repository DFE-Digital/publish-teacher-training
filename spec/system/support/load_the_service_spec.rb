# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Support", service: :publish do
  include DfESignInUserHelper

  let(:provider) { create(:provider, provider_name: "System Provider") }
  let(:user) { create(:user, :admin, providers: [provider]) }

  before do
    sign_in_system_test(user:)
  end

  it "shows the support page" do
    visit "/publish/organisations"
    click_on("Support console")
    expect(page).to have_current_path(%r{/support})
    expect(page).to have_content("System Provider")
  end
end
