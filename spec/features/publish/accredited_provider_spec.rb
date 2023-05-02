# frozen_string_literal: true

require 'rails_helper'

feature 'Accredited provider flow', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_a_lead_school_provider_user
    and_the_accredited_provider_search_feature_is_on
    and_my_provider_has_accredited_providers
  end

  scenario 'i can view the accredited providers tab when there are none' do
    when_i_visit_the_root_path
    and_i_click_on_the_accredited_provider_tab
    then_i_see_the_correct_text_for_no_accredited_providers
  end

  private

  def then_i_see_the_correct_text_for_no_accredited_providers
    expect(page).to have_text("There are no accredited providers for #{@provider.provider_name}")
  end

  def and_i_click_on_the_accredited_provider_tab
    click_link 'Accredited provider'
  end

  def when_i_visit_the_root_path
    visit root_path
  end

  def and_the_accredited_provider_search_feature_is_on
    allow(Settings.features).to receive(:accredited_provider_search).and_return(true)
  end

  def given_i_am_a_lead_school_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
    @provider = @current_user.providers.first
  end

  def and_my_provider_has_accredited_providers
    @provider.courses << create(:course, :with_accrediting_provider)
    @accrediting_provider = @provider.accrediting_providers.first
  end
end
