# frozen_string_literal: true

require "rails_helper"

feature "Viewing provider users" do
  scenario "i can view associated users" do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_provider_users_page
    then_i_can_view_users_associated_with_the_provider
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_provider_users_page
    provider_users_page.load(provider_code: provider.provider_code)
  end

  def then_i_can_view_users_associated_with_the_provider
    expect(provider_users_page.heading.text).to eq("Users")
    expect(provider_users_page.user_name.text).to eq("#{@user.first_name} #{@user.last_name}")
  end

  def provider
    @current_user.providers.first
  end
end
