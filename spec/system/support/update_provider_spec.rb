# frozen_string_literal: true

require 'spec_helper'
RSpec.describe 'Removing accredited status from provider', service: :publish do
  include DfESignInUserHelper
  let(:provider) { create(:provider, :accredited_provider, provider_name: 'Pro Vider') }
  let(:user) { create(:user, :admin, providers: [provider]) }

  before do
    sign_in_system_test(user:)
  end

  it 'accredited provider number is cleared' do
    visit "/support/#{RecruitmentCycle.current.year}/providers"

    click_on 'Pro Vider'
    expect(page).to have_current_path("/support/#{RecruitmentCycle.current.year}/providers/#{provider.id}")

    within '[data-qa="ap-number-row"]' do
      expect(page.find('.govuk-summary-list__value').text).to eq(provider.accredited_provider_number.to_s)
      click_on('Change')
    end
    page.find_by_id('provider-accredited-field', visible: false).click

    click_on 'Update organisation details'
    expect(page).to have_current_path("/support/#{RecruitmentCycle.current.year}/providers/#{provider.id}")
    expect(provider.reload.accredited_provider_number).to be_blank
  end
end
