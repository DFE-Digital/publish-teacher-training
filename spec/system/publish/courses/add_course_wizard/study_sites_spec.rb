# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard study sites step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_multiple_schools
  end

  scenario "choosing a study site and continues to courses index page" do
    when_i_visit_the_wizard_study_sites_page
    and_i_choose_a_study_site_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_courses_index_page
  end

private

  def when_i_visit_the_wizard_study_sites_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :study_sites,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_a_study_site_from_the_list
    check provider.study_sites.first.location_name
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_courses_index_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_courses_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
      ),
      ignore_query: true,
    )
  end

  def given_i_am_authenticated_as_a_provider_user_with_multiple_schools
    @user = create(
      :user,
      providers: [
        create(
          :provider,
          :accredited_provider,
          sites: [
            build(:site),
            build(:site),
            build(:site, :study_site),
            build(:site, :study_site),
          ],
        ),
      ],
    )

    given_i_am_authenticated(user: @user)
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
