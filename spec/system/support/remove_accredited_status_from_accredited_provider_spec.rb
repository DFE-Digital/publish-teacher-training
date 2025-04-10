# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::UpdateProviders", service: :publish do
  include DfESignInUserHelper
  before do
    driven_by(:rack_test)
    sign_in_system_test(user:)
  end

  let(:user) { create(:user, :admin, providers: [build(:provider)]) }
  let(:accredited_provider) { create(:accredited_provider, provider_name: "MyAccredited") }
  let!(:providers) { [build(:provider), accredited_provider] }

  it "Remove accredited status from accredited provider" do
    visit "/support/#{RecruitmentCycle.current.year}/providers"

    expect(page).to have_content("MyAccredited")
    click_on accredited_provider.provider_name
    expect(page).to have_css(:h1, text: accredited_provider.provider_name)

    expect(page).to have_content("Is the organisation an accredited provider?Yes")
    expect(page).to have_content("Accredited provider number")
    click_on "Change accredited provider"
    within_fieldset("Is the organisation an accredited provider?") do
      choose "No", disabled: false
    end
    click_on "Update organisation details"
    expect(page).to have_content("Provider successfully updated")
    expect(page).to have_content("Is the organisation an accredited provider?No")
    expect(page).to have_no_content("Accredited provider number")
  end
end
