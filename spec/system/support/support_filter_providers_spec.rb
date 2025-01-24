# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Support::FilterProviders', service: :publish do
  include DfESignInUserHelper
  before do
    driven_by(:rack_test)
    sign_in_system_test(user:)
  end

  let(:user) { create(:user, :admin, providers: [provider]) }
  let(:provider) { create(:provider, provider_name: 'MyProvider') }
  let(:accredited_provider) { create(:accredited_provider, provider_name: 'MyAccredited') }
  let!(:providers) { [provider, accredited_provider] }

  it 'filters accredited providers' do
    visit "/support/#{RecruitmentCycle.current.year}/providers"

    expect(page).to have_content('MyAccredited')
    expect(page).to have_content('MyProvider')
    check 'Accredited providers'
    click_on 'Apply filters'
    expect(page).to have_no_content('MyProvider')
  end
end
