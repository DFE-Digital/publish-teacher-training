# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Removing a school from a provider" do
  scenario "from the support console" do
    given_i_am_authenticated_as_an_admin
    and_the_provider_has_two_schools

    when_i_view_the_support_schools_list
    and_i_view_the_school_in_publish
    and_i_remove_the_school_from_the_provider_account

    then_i_am_back_on_the_support_schools_list
    and_i_see_the_school_has_been_removed_from_the_provider
    and_the_school_is_no_longer_on_the_provider
  end

  scenario "from publish" do
    given_i_am_authenticated_as_a_provider_user
    and_the_provider_has_a_second_school

    when_i_open_the_school_in_publish
    and_i_remove_the_school_from_the_provider_account

    then_i_am_on_the_publish_schools_list
    and_i_see_the_school_has_been_removed_from_the_account
    and_the_school_is_no_longer_on_the_provider
  end

private

  def given_i_am_authenticated_as_an_admin
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, providers: [provider]))
  end

  def and_the_provider_has_two_schools
    provider
    school
    second_school
  end

  alias_method :and_the_provider_has_a_second_school, :and_the_provider_has_two_schools

  def provider
    @provider ||= create(:provider, provider_name: "2Schools Consortium")
  end

  def school
    @school ||= begin
      gias_school = create(:gias_school, name: "Bush Hill Park Primary School")
      site = create(:site, provider:, **gias_school.school_attributes)
      create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid)
    end
  end

  def second_school
    @second_school ||= create(:provider_school, provider:, site_code: "Z")
  end

  def when_i_view_the_support_schools_list
    visit support_recruitment_cycle_provider_schools_path(provider.recruitment_cycle_year, provider)
  end

  def and_i_view_the_school_in_publish
    within("tr", text: school.location_name) do
      click_link "View school"
    end
  end

  def when_i_open_the_school_in_publish
    visit publish_provider_recruitment_cycle_school_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      school.uuid,
    )
  end

  def and_i_remove_the_school_from_the_provider_account
    click_link "Remove #{school.decorate.location_name} from your account"
    click_button "Remove school from account"
  end

  def then_i_am_back_on_the_support_schools_list
    expect(page).to have_current_path(
      support_recruitment_cycle_provider_schools_path(provider.recruitment_cycle_year, provider),
      ignore_query: true,
    )
  end

  def then_i_am_on_the_publish_schools_list
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_schools_path(provider.provider_code, provider.recruitment_cycle_year),
      ignore_query: true,
    )
  end

  def and_i_see_the_school_has_been_removed_from_the_provider
    expect(page).to have_content("#{school.decorate.location_name} has been removed from #{provider.provider_name}")
  end

  def and_i_see_the_school_has_been_removed_from_the_account
    expect(page).to have_content("#{school.decorate.location_name} has been removed from your account")
  end

  def and_the_school_is_no_longer_on_the_provider
    expect(provider.schools.reload).not_to include(school)
  end
end
