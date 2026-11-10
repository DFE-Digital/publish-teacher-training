# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::UpdateProviders", service: :publish do
  include DfESignInUserHelper
  before do
    driven_by(:rack_test)
    sign_in_system_test(user:)
  end

  let(:user) { create(:user, :admin, providers: [build(:provider)]) }
  let(:accredited_provider) { create(:accredited_provider, provider_name: "MyAccredited", accredited_provider_number: 1234) }
  let!(:providers) { [build(:provider), accredited_provider] }

  it "Remove accredited status from accredited provider" do
    visit "/support/#{RecruitmentCycle.current.year}/providers"

    expect(page).to have_content("MyAccredited")
    click_on accredited_provider.provider_name
    click_on "Organisation"
    expect(page).to have_css("h1", text: accredited_provider.provider_name)

    expect(provider_table_cell("Accredited provider number").text).to eq("1234")
    provider_table_cell("Provider name").click_link(accredited_provider.provider_name)
    within_fieldset("Is the organisation an accredited provider?") do
      choose "No", disabled: false
    end
    click_on "Update organisation details"
    expect(page).to have_content("Provider updated")
    expect(provider_table_cell("Accredited provider number").text).to be_blank
  end

  def provider_table_cell(heading)
    headings = page.all("table.govuk-table thead th").map(&:text)

    page.all("table.govuk-table tbody td")[headings.index(heading)]
  end
end
