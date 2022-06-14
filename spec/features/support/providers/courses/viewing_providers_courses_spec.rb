# frozen_string_literal: true

require "rails_helper"

feature "Viewing a providers courses" do
  scenario "Provider is discarded" do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_discarded_provider_with_courses
    when_i_visit_the_support_courses_index_page
    then_i_am_redirected_to_the_providers_page
  end

private

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def provider
    @provider ||= create(:provider, courses: [build(:course)], discarded_at: Time.zone.now)
  end

  def and_there_is_a_discarded_provider_with_courses
    provider
  end

  def when_i_visit_the_support_courses_index_page
    support_courses_index_page.load(provider_id: provider.id)
  end

  def then_i_am_redirected_to_the_providers_page
    expect(support_provider_index_page).to be_displayed
  end
end
