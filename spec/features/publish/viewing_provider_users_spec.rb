# frozen_string_literal: true

# This file can be deleted once the "user_management" feature flag is removed

require 'rails_helper'

feature 'Viewing provider users' do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_the_user_management_feature_flag_is_inactive
    when_i_visit_the_publish_provider_users_page
  end

  scenario 'i can view associated users' do
    then_i_can_view_users_associated_with_the_provider
  end

  scenario 'i can view request access form' do
    and_i_click_on_request_access_for_someone_else
    then_i_see_the_request_access_form
  end

  private

  def then_i_see_the_request_access_form
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/request-access")
  end

  def and_i_click_on_request_access_for_someone_else
    publish_provider_users_page.request_access.click
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_publish_provider_users_page
    publish_provider_users_page.load(provider_code: provider.provider_code)
  end

  def then_i_can_view_users_associated_with_the_provider
    expect(publish_provider_users_page.heading.text).to eq('Users')
    expect(publish_provider_users_page.user_name.text).to eq("#{@user.first_name} #{@user.last_name}")
  end

  def provider
    @current_user.providers.first
  end

  def and_the_user_management_feature_flag_is_inactive
    allow(Settings.features).to receive(:user_management).and_return(false)
  end
end
